"use client";

import React from "react";
import { 
  LayoutDashboard, 
  ShoppingBag, 
  Users, 
  Package, 
  Settings, 
  Bell, 
  HelpCircle,
  LogOut,
  Layers,
  Tag,
  CreditCard,
  Megaphone,
  Store,
  MessageSquare,
  Calendar
} from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { auth } from "@/lib/firebase";

import { useAuth } from "@/context/AuthContext";

export function Sidebar() {
  const pathname = usePathname();
  const { user, role } = useAuth();

  const allMenuItems = [
    { icon: LayoutDashboard, label: "Dashboard", href: "/", roles: ["admin", "staff"] },
    { icon: Megaphone, label: "Broadcasts", href: "/broadcasts", roles: ["admin"] },
    { icon: Tag, label: "Events", href: "/events", roles: ["admin", "staff"] },
    { icon: Calendar, label: "Schedules", href: "/schedules", roles: ["admin"] },
    { icon: MessageSquare, label: "Complaints", href: "/complaints", roles: ["admin", "staff"] },
    { icon: LayoutDashboard, label: "Task Board", href: "/tasks", roles: ["admin"] },
    { icon: Users, label: "Users", href: "/users", roles: ["admin"] },
    { icon: Layers, label: "Assignments", href: "/assignments", roles: ["admin"] },
  ];

  const menuItems = allMenuItems.filter(item => item.roles.includes(role || ""));

  const secondaryItems = [
    { icon: Settings, label: "Settings", href: "/settings" },
    { icon: HelpCircle, label: "Support", href: "/support" },
  ];

  const userName = user?.displayName || user?.email?.split('@')[0] || "User";
  const displayRole = role === "admin" ? "System Admin" : role === "staff" ? "Campus Staff" : "Guest";

  return (
    <aside className="fixed left-6 top-6 bottom-6 w-72 z-50 flex flex-col">
      <div className="h-full bg-[#161616]/90 backdrop-blur-3xl rounded-[2.5rem] border border-[#2A2A2A] shadow-[0_20px_50px_rgba(0,0,0,0.8)] flex flex-col overflow-hidden relative">
        
        {/* Subtle Background Glows */}
        <div className="absolute -top-20 -left-20 w-40 h-40 bg-[#D4AF37]/5 blur-[80px] rounded-full" />
        <div className="absolute -bottom-20 -right-20 w-40 h-40 bg-amber-600/5 blur-[80px] rounded-full" />

        {/* Branding */}
        <div className="p-10 pb-6 relative z-10">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 bg-transparent flex items-center justify-center rounded-2xl overflow-hidden">
              <img src="/app_logo.png" alt="CampusOne" className="w-full h-full object-contain" />
            </div>
            <div>
              <span className="text-2xl font-black text-white tracking-tighter uppercase italic block leading-none">CampusOne</span>
              <div className="flex items-center gap-2 mt-1.5">
                <div className="w-1.5 h-1.5 rounded-full bg-[#D4AF37] shadow-[0_0_10px_rgba(212,175,55,0.5)]" />
                <span className="text-[8px] font-black text-[#f3f4f6]/70 uppercase tracking-[0.3em]">{role === 'staff' ? 'Staff Portal' : 'Admin Center'}</span>
              </div>
            </div>
          </div>
        </div>

        {/* Navigation */}
        <nav className="flex-1 px-6 overflow-y-auto space-y-10 relative z-10 custom-scrollbar mt-4">
          <div>
            <p className="text-[9px] font-black text-[#f3f4f6]/50 uppercase tracking-[0.5em] px-4 mb-5">Main Console</p>
            <div className="space-y-2">
              {menuItems.map((item) => {
                const isActive = pathname === item.href;
                return (
                  <Link 
                    key={item.href} 
                    href={item.href}
                    className={`flex items-center gap-4 px-5 py-4 rounded-2xl transition-all duration-500 group relative ${
                      isActive 
                        ? "bg-[#D4AF37] text-[#0A0A0A] shadow-[0_10px_30px_rgba(212,175,55,0.2)]" 
                        : "text-[#f3f4f6]/70 hover:text-[#D4AF37] hover:bg-[#D4AF37]/5"
                    }`}
                  >
                    <item.icon size={18} className={isActive ? "text-[#0A0A0A]" : "group-hover:text-[#D4AF37] transition-colors duration-300"} />
                    <span className="font-black text-[11px] uppercase tracking-[0.1em]">{item.label}</span>
                  </Link>
                );
              })}
            </div>
          </div>

          <div>
            <p className="text-[9px] font-black text-[#f3f4f6]/50 uppercase tracking-[0.5em] px-4 mb-5">System Tools</p>
            <div className="space-y-2">
              {secondaryItems.map((item) => {
                const isActive = pathname === item.href;
                return (
                  <Link 
                    key={item.href} 
                    href={item.href}
                    className={`flex items-center gap-4 px-5 py-4 rounded-2xl transition-all duration-500 group ${
                      isActive 
                        ? "bg-[#D4AF37]/10 text-[#D4AF37] border border-[#D4AF37]/20 shadow-xl" 
                        : "text-[#f3f4f6]/70 hover:text-[#D4AF37] hover:bg-[#D4AF37]/5"
                    }`}
                  >
                    <item.icon size={18} className={isActive ? "text-[#D4AF37]" : "group-hover:text-[#D4AF37] transition-all"} />
                    <span className="font-black text-[11px] uppercase tracking-[0.1em]">{item.label}</span>
                  </Link>
                );
              })}
            </div>
          </div>
        </nav>

        {/* Footer: User Status */}
        <div className="p-8 relative z-10 mt-auto">
          <div className="p-6 bg-[#D4AF37]/5 rounded-[2rem] border border-[#D4AF37]/10 backdrop-blur-xl">
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-[#D4AF37] to-amber-600 flex items-center justify-center text-[#0A0A0A] font-black text-xs shadow-lg border border-white/10 uppercase">
                {userName.charAt(0)}
              </div>
              <div className="overflow-hidden">
                <p className="text-xs font-black text-white leading-none truncate mb-1 uppercase">{userName}</p>
                <p className="text-[8px] font-black text-[#D4AF37] uppercase tracking-widest">{displayRole}</p>
              </div>
            </div>
            <button 
              onClick={() => auth.signOut()}
              className="w-full mt-5 flex items-center justify-center gap-2 py-3.5 rounded-xl text-[9px] font-black uppercase tracking-[0.2em] text-[#D4AF37] bg-[#D4AF37]/10 hover:bg-[#D4AF37] hover:text-[#0A0A0A] transition-all duration-500 border border-[#D4AF37]/20"
            >
              <LogOut size={14} />
              Terminal Logout
            </button>
          </div>
        </div>
      </div>
    </aside>
  );
}
