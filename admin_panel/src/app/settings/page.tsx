"use client";

import React, { useEffect, useState } from "react";
import { Sidebar } from "@/components/Sidebar";
import { 
  Settings, 
  Save, 
  Loader2, 
  Globe, 
  Shield, 
  Mail, 
  Phone, 
  DollarSign,
  MonitorOff,
  BellRing
} from "lucide-react";
import { doc, getDoc, setDoc, serverTimestamp } from "firebase/firestore";
import { db } from "@/lib/firebase";

export default function SettingsPage() {
  const [settings, setSettings] = useState({
    storeName: "EthioShop",
    contactEmail: "support@ethioshop.com",
    contactPhone: "+251 911 000 000",
    currency: "USD",
    isMaintenanceMode: false,
    welcomeMessage: "Welcome to our premium store!",
    facebookUrl: "",
    instagramUrl: ""
  });
  const [fetching, setFetching] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    fetchSettings();
  }, []);

  const fetchSettings = async () => {
    try {
      const snap = await getDoc(doc(db, "settings", "app"));
      if (snap.exists()) {
        setSettings({ ...settings, ...snap.data() });
      }
    } catch (error) {
      console.error(error);
    } finally {
      setFetching(false);
    }
  };

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    try {
      await setDoc(doc(db, "settings", "app"), {
        ...settings,
        updatedAt: serverTimestamp(),
      });
      alert("System updated successfully!");
    } catch (error) {
      alert("Error saving settings");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="flex min-h-screen bg-[#0A0A0A] text-[#f3f4f6]">
      <Sidebar />
      <main className="flex-1 ml-80 p-10">
        <header className="flex justify-between items-end mb-12">
          <div>
            <div className="flex items-center gap-3 mb-2">
              <div className="w-1.5 h-6 bg-[#D4AF37] rounded-full" />
              <p className="text-[10px] font-black text-stone-400 uppercase tracking-[0.4em]">Core Infrastructure</p>
            </div>
            <h1 className="text-6xl font-black text-white uppercase italic tracking-tighter leading-none">System Configuration</h1>
          </div>
          <div className="text-right">
            <p className="text-[10px] font-black text-stone-400 uppercase tracking-widest mb-1">Global Control</p>
            <p className="text-xs font-bold text-[#D4AF37] uppercase italic">Royal Console Connected</p>
          </div>
        </header>

        <form onSubmit={handleSave} className="grid grid-cols-1 lg:grid-cols-2 gap-12">
          {/* General Store Settings */}
          <div className="space-y-12">
            <div className="premium-card p-10 space-y-8">
              <h3 className="text-[10px] font-black text-[#D4AF37] uppercase tracking-[0.4em] flex items-center gap-2">
                <Globe size={14} /> Identity & Localization
              </h3>
              
              <div className="space-y-3">
                <label className="text-[10px] font-black text-stone-400 uppercase tracking-widest px-1">Store Brand Name</label>
                <input 
                  value={settings.storeName}
                  onChange={(e) => setSettings({...settings, storeName: e.target.value})}
                  className="terminal-input w-full"
                />
              </div>

              <div className="grid grid-cols-2 gap-6">
                <div className="space-y-3">
                  <label className="text-[10px] font-black text-stone-400 uppercase tracking-widest px-1">Currency Code</label>
                  <input 
                    value={settings.currency}
                    onChange={(e) => setSettings({...settings, currency: e.target.value})}
                    className="terminal-input w-full"
                    placeholder="USD or ETB"
                  />
                </div>
                <div className="space-y-3">
                  <label className="text-[10px] font-black text-stone-400 uppercase tracking-widest px-1">Contact Phone</label>
                  <input 
                    value={settings.contactPhone}
                    onChange={(e) => setSettings({...settings, contactPhone: e.target.value})}
                    className="terminal-input w-full"
                  />
                </div>
              </div>

              <div className="space-y-3">
                <label className="text-[10px] font-black text-stone-400 uppercase tracking-widest px-1">Support Email Address</label>
                <input 
                  value={settings.contactEmail}
                  onChange={(e) => setSettings({...settings, contactEmail: e.target.value})}
                  className="terminal-input w-full"
                />
              </div>
            </div>

            <div className="premium-card p-10 space-y-8">
              <h3 className="text-[10px] font-black text-[#D4AF37] uppercase tracking-[0.4em] flex items-center gap-2">
                <BellRing size={14} /> App Announcements
              </h3>
              <div className="space-y-3">
                <label className="text-[10px] font-black text-stone-400 uppercase tracking-widest px-1">Home Welcome Message</label>
                <textarea 
                  rows={4}
                  value={settings.welcomeMessage}
                  onChange={(e) => setSettings({...settings, welcomeMessage: e.target.value})}
                  className="terminal-input w-full resize-none"
                />
              </div>
            </div>
          </div>

          {/* Security & Maintenance */}
          <div className="space-y-12">
            <div className="premium-card p-10 border-red-500/20 bg-red-500/5 hover:bg-red-500/10 transition-all duration-700">
              <div className="flex justify-between items-start mb-8">
                <div>
                  <h3 className="text-[10px] font-black text-red-500 uppercase tracking-[0.4em] flex items-center gap-2">
                    <Shield size={14} /> Critical Switch
                  </h3>
                  <p className="text-[11px] text-white font-black uppercase italic tracking-tighter mt-1">Maintenance Mode</p>
                </div>
                <div 
                  onClick={() => setSettings({...settings, isMaintenanceMode: !settings.isMaintenanceMode})}
                  className={`w-16 h-8 rounded-full transition-all cursor-pointer relative border border-white/10 ${settings.isMaintenanceMode ? 'bg-red-500 shadow-[0_0_20px_rgba(239,68,68,0.4)]' : 'bg-stone-900'}`}
                >
                  <div className={`absolute top-1.5 w-4 h-4 bg-white rounded-full transition-all duration-500 ${settings.isMaintenanceMode ? 'left-10' : 'left-2'}`}></div>
                </div>
              </div>
              
              <div className="flex gap-6 items-start p-6 bg-black/50 rounded-3xl border border-white/5">
                <div className={`p-4 rounded-2xl ${settings.isMaintenanceMode ? 'bg-red-500/20 text-red-500' : 'bg-stone-800 text-stone-400'}`}>
                  <MonitorOff size={24} />
                </div>
                <div>
                  <p className="text-sm font-black text-white uppercase tracking-tight">Public Visibility</p>
                  <p className="text-[11px] text-stone-400 leading-relaxed mt-1 font-medium">
                    When active, all external storefronts will display a "Closed for Updates" screen. Use this only for critical database migrations.
                  </p>
                </div>
              </div>
            </div>

            <button 
              type="submit" 
              disabled={saving}
              className="w-full h-24 bg-[#D4AF37] hover:bg-[#B8962E] text-[#0A0A0A] font-black rounded-3xl flex items-center justify-center gap-4 transition-all duration-500 shadow-2xl shadow-[#D4AF37]/10 group active:scale-95"
            >
              {saving ? (
                <Loader2 className="animate-spin" />
              ) : (
                <>
                  <Save size={24} className="group-hover:scale-125 transition-transform" />
                  <span className="text-xl uppercase italic tracking-tighter">Authorize Global Deployment</span>
                </>
              )}
            </button>

            <div className="p-8 border border-white/5 rounded-[2.5rem] bg-white/[0.01]">
               <p className="text-[9px] font-black text-stone-500 uppercase tracking-[0.3em] text-center">
                 Secure Connection ID: {Math.random().toString(36).substring(7).toUpperCase()}
               </p>
            </div>
          </div>
        </form>
      </main>
    </div>
  );
}

