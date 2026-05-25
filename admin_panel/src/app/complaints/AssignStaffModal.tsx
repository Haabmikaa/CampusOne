"use client";

import React, { useState, useEffect } from "react";
import { X, Search, Building, User, ChevronRight, Loader2 } from "lucide-react";

interface Staff {
  id: string;
  name: string;
  department?: string;
  role: string;
}

interface AssignStaffModalProps {
  isOpen: boolean;
  onClose: () => void;
  onAssign: (staffId: string) => void;
  staffMembers: Staff[];
}

export default function AssignStaffModal({ isOpen, onClose, onAssign, staffMembers }: AssignStaffModalProps) {
  const [search, setSearch] = useState("");
  const [selectedDept, setSelectedDept] = useState("All");

  const departments = ["All", ...Array.from(new Set(staffMembers.map(s => s.department || "General"))).sort()];

  if (!isOpen) return null;

  const filteredStaff = staffMembers.filter(s => {
    const matchesSearch = s.name.toLowerCase().includes(search.toLowerCase());
    const matchesDept = selectedDept === "All" || (s.department || "General") === selectedDept;
    return matchesSearch && matchesDept;
  });

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-in fade-in duration-300">
      <div className="bg-[#161616] border border-[#2A2A2A] rounded-[2.5rem] w-full max-w-2xl overflow-hidden shadow-[0_0_100px_rgba(0,0,0,0.5)] flex flex-col max-h-[85vh]">
        
        {/* Header */}
        <div className="p-8 border-b border-[#2A2A2A] flex items-center justify-between">
          <div>
            <h2 className="text-2xl font-black text-white uppercase italic tracking-tighter flex items-center gap-3">
              <User size={24} className="text-red-500" />
              Assign Resolver
            </h2>
            <p className="text-[10px] font-black text-stone-500 uppercase tracking-[0.3em] mt-1">Select the best staff for this task</p>
          </div>
          <button onClick={onClose} className="p-3 hover:bg-white/5 rounded-full text-stone-500 hover:text-white transition-all">
            <X size={24} />
          </button>
        </div>

        {/* Search & Filter */}
        <div className="p-8 pb-4 space-y-6">
          <div className="relative group">
            <Search size={18} className="absolute left-4 top-1/2 -translate-y-1/2 text-stone-500 group-focus-within:text-red-500 transition-colors" />
            <input
              autoFocus
              type="text"
              placeholder="Search staff by name..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full bg-black border border-[#2A2A2A] rounded-2xl pl-12 pr-4 py-4 text-sm text-white focus:outline-none focus:border-red-500 transition-all placeholder:text-stone-600"
            />
          </div>

          <div className="flex gap-2 overflow-x-auto pb-2 custom-scrollbar no-scrollbar">
            {departments.map((dept) => (
              <button
                key={dept}
                onClick={() => setSelectedDept(dept)}
                className={`px-5 py-2.5 rounded-xl text-[10px] font-black uppercase tracking-widest whitespace-nowrap transition-all ${
                  selectedDept === dept
                    ? "bg-red-500 text-white shadow-lg shadow-red-500/20"
                    : "bg-[#161616] border border-[#2A2A2A] text-stone-500 hover:text-white"
                }`}
              >
                {dept}
              </button>
            ))}
          </div>
        </div>

        {/* Staff List */}
        <div className="flex-1 overflow-y-auto p-8 pt-0 custom-scrollbar">
          <div className="grid grid-cols-1 gap-3">
            {filteredStaff.map((staff) => (
              <button
                key={staff.id}
                onClick={() => {
                  onAssign(staff.id);
                  onClose();
                }}
                className="flex items-center justify-between p-5 bg-black/40 border border-[#2A2A2A] rounded-2xl group hover:border-red-500/50 hover:bg-red-500/5 transition-all text-left"
              >
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 rounded-xl bg-gradient-to-tr from-red-500/20 to-rose-500/10 border border-red-500/20 flex items-center justify-center text-red-500 group-hover:scale-110 transition-transform">
                    <User size={20} />
                  </div>
                  <div>
                    <h3 className="font-black text-white uppercase tracking-tight group-hover:text-red-500 transition-colors">{staff.name}</h3>
                    <div className="flex items-center gap-2 mt-1">
                      <Building size={12} className="text-stone-600" />
                      <span className="text-[10px] font-black text-stone-500 uppercase tracking-widest">{staff.department || "General"}</span>
                    </div>
                  </div>
                </div>
                <div className="p-2 rounded-lg bg-stone-900 group-hover:bg-red-500 group-hover:text-black transition-all">
                  <ChevronRight size={18} />
                </div>
              </button>
            ))}

            {filteredStaff.length === 0 && (
              <div className="py-20 text-center text-stone-600">
                <Search size={40} className="mx-auto mb-4 opacity-20" />
                <p className="font-black uppercase tracking-widest text-xs">No matching staff found</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
