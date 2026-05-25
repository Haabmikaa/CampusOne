"use client";

import React, { useState } from "react";
import { signInWithEmailAndPassword, GoogleAuthProvider, signInWithRedirect } from "firebase/auth";
import { auth } from "@/lib/firebase";
import { ShieldAlert, LogIn, Lock, Mail, Fingerprint, Loader2 } from "lucide-react";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [googleLoading, setGoogleLoading] = useState(false);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    try {
      await signInWithEmailAndPassword(auth, email, password);
    } catch (err: any) {
      setError(err.message || "Authentication protocol failed. Identity unverified.");
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleLogin = async () => {
    setGoogleLoading(true);
    setError("");
    try {
      const provider = new GoogleAuthProvider();
      const { signInWithPopup } = await import("firebase/auth");
      await signInWithPopup(auth, provider);
    } catch (err: any) {
      setError(err.message || "OAuth handshake failed.");
      setGoogleLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#0A0A0A] flex items-center justify-center p-6 relative overflow-hidden">
      {/* Ambient Background Elements */}
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-[#D4AF37]/5 blur-[150px] rounded-full pointer-events-none" />
      
      <div className="w-full max-w-lg relative z-10">
        <div className="premium-card p-12 bg-[#161616] border-[#2A2A2A] shadow-2xl relative overflow-hidden group">
          <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-transparent via-[#D4AF37] to-transparent opacity-50" />
          
          <div className="flex flex-col items-center mb-10">
            <div className="relative mb-6">
              <div className="absolute inset-0 bg-[#D4AF37]/10 blur-xl rounded-full animate-pulse" />
              <div className="w-24 h-24 bg-[#0A0A0A] border border-[#2A2A2A] rounded-3xl flex items-center justify-center relative z-10 shadow-xl overflow-hidden group-hover:border-[#D4AF37] transition-colors duration-500 p-2">
                <div className="absolute inset-0 bg-gradient-to-tr from-[#D4AF37]/5 to-transparent opacity-50" />
                <img src="/app_logo.png" alt="App Logo" className="w-full h-full object-contain relative z-10" />
              </div>
            </div>
            <h1 className="text-3xl font-black text-white uppercase italic tracking-tighter leading-none mb-2">Master Console</h1>
            <div className="flex items-center gap-2 px-3 py-1 bg-[#D4AF37]/10 rounded-full border border-[#D4AF37]/20">
              <ShieldAlert size={12} className="text-[#D4AF37]" />
              <p className="text-[9px] text-[#D4AF37] font-black uppercase tracking-[0.2em]">Level 5 Clearance Required</p>
            </div>
          </div>

          <form onSubmit={handleLogin} className="space-y-6 relative z-10">
            <div className="space-y-2">
              <label className="text-[10px] font-black text-[#f3f4f6]/70 uppercase tracking-widest px-1">Admin Identity (Email)</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-5 flex items-center pointer-events-none text-[#f3f4f6]/70">
                  <Mail size={18} />
                </div>
                <input 
                  type="email" 
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="terminal-input w-full pl-14"
                  placeholder="admin@ethioshop.com"
                />
              </div>
            </div>

            <div className="space-y-2">
              <label className="text-[10px] font-black text-[#f3f4f6]/70 uppercase tracking-widest px-1">Access Cipher (Password)</label>
              <div className="relative">
                <div className="absolute inset-y-0 left-5 flex items-center pointer-events-none text-[#f3f4f6]/70">
                  <Lock size={18} />
                </div>
                <input 
                  type="password" 
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="terminal-input w-full pl-14 tracking-widest"
                  placeholder="••••••••••••"
                />
              </div>
            </div>

            {error && (
              <div className="p-4 bg-red-500/10 border border-red-500/20 rounded-2xl text-red-400 text-xs font-bold text-center flex items-center justify-center gap-2">
                <ShieldAlert size={14} />
                {error}
              </div>
            )}

            <button 
              type="submit"
              disabled={loading || googleLoading}
              className="w-full h-16 bg-[#D4AF37] hover:bg-[#B8962E] text-[#0A0A0A] font-black rounded-2xl flex items-center justify-center gap-3 transition-all duration-500 shadow-xl shadow-[#D4AF37]/20 disabled:opacity-50 disabled:cursor-not-allowed mt-4"
            >
              {loading ? (
                <>
                  <Loader2 size={20} className="animate-spin" />
                  <span className="text-sm uppercase italic tracking-tighter">Decrypting Identity...</span>
                </>
              ) : (
                <>
                  <LogIn size={20} />
                  <span className="text-sm uppercase italic tracking-tighter">Authorize Access</span>
                </>
              )}
            </button>
          </form>

          <div className="relative my-10 z-10">
            <div className="absolute inset-0 flex items-center">
              <div className="w-full border-t border-[#2A2A2A]"></div>
            </div>
            <div className="relative flex justify-center text-xs uppercase">
              <span className="bg-[#161616] px-4 text-[10px] text-[#f3f4f6]/70 font-black tracking-[0.3em] italic">Secondary Protocol</span>
            </div>
          </div>

          <button 
            onClick={handleGoogleLogin}
            disabled={loading || googleLoading}
            className="w-full h-14 bg-white/5 hover:bg-white/10 border border-[#2A2A2A] text-white font-black rounded-2xl flex items-center justify-center gap-3 transition-all disabled:opacity-50 relative z-10 group"
          >
            {googleLoading ? (
              <Loader2 size={18} className="animate-spin" />
            ) : (
              <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" alt="Google" className="w-5 h-5 group-hover:scale-110 transition-transform" />
            )}
            <span className="text-xs uppercase tracking-widest">Authenticate with Google</span>
          </button>
          
          <div className="mt-8 text-center relative z-10">
            <p className="text-[9px] font-black text-stone-400 uppercase tracking-[0.3em]">
              Secure Connection ID: {Math.random().toString(36).substring(7).toUpperCase()}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
