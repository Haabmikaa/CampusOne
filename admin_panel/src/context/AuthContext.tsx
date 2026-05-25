"use client";

import React, { createContext, useContext, useEffect, useState } from "react";
import { 
  onAuthStateChanged, 
  User, 
  setPersistence, 
  browserLocalPersistence,
  getRedirectResult 
} from "firebase/auth";
import { doc, getDoc } from "firebase/firestore";
import { auth, db } from "@/lib/firebase";

interface AuthContextType {
  user: User | null;
  role: string | null;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType>({
  user: null,
  role: null,
  loading: true,
});

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [role, setRole] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {


    const initAuth = async () => {
      try {
        await setPersistence(auth, browserLocalPersistence);
        const result = await getRedirectResult(auth);
        if (result?.user) {
          console.log("Redirect Login Successful:", result.user.email);
        }
      } catch (error) {
        console.error("Redirect Error:", error);
      }
    };

    initAuth();

    const unsubscribe = onAuthStateChanged(auth, async (currUser) => {
      console.log("Auth State Changed. User:", currUser?.email);
      try {
        if (currUser) {
          setUser(currUser);
          
          // Secure Master Admin Auto-Assignment
          const isMasterAdmin = currUser.email === "haabmikaa@gmail.com";
          
          const userRef = doc(db, "users", currUser.uid);
          const userDoc = await getDoc(userRef);
          
          if (userDoc.exists()) {
            const userData = userDoc.data();
            console.log("Role found:", userData.role);
            
            if (isMasterAdmin && userData.role !== "admin") {
               // Upgrade to admin automatically
               const { updateDoc } = await import("firebase/firestore");
               await updateDoc(userRef, { role: "admin" });
               setRole("admin");
            } else {
               setRole(userData.role || "customer");
            }
          } else {
            console.warn("No user document found in Firestore. Creating one...");
            const { setDoc, serverTimestamp } = await import("firebase/firestore");
            const newRole = isMasterAdmin ? "admin" : "customer";
            await setDoc(userRef, {
              email: currUser.email,
              name: currUser.displayName || "Unknown User",
              role: newRole,
              createdAt: serverTimestamp(),
            });
            setRole(newRole);
          }
        } else {
          setUser(null);
          setRole(null);
        }
      } catch (error) {
        console.error("Critical Auth/Firestore Error:", error);
      } finally {
        setLoading(false);
      }
    });

    return () => unsubscribe();
  }, []);

  return (
    <AuthContext.Provider value={{ user, role, loading }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
