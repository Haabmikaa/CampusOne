"use client";

import React from "react";
import { useAuth } from "@/context/AuthContext";
import LoginPage from "@/components/LoginPage";

export default function AdminGuard({ children }: { children: React.ReactNode }) {
  const { user, role, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen bg-[#0A0A0A] flex items-center justify-center">
        <div className="relative">
          <div className="h-24 w-24 rounded-full border-t-4 border-b-4 border-[#D4AF37] animate-spin"></div>
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 font-black text-[#D4AF37] italic">S</div>
        </div>
        <p className="absolute mt-32 text-[10px] font-black text-[#D4AF37] uppercase tracking-[0.5em] animate-pulse">Establishing Secure Link...</p>
      </div>
    );
  }

  // If not logged in, or not an admin, show the login page
  if (!user || role !== "admin") {
    return <LoginPage />;
  }

  // Otherwise, render the protected content
  return <>{children}</>;
}
