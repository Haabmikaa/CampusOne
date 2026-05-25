"use client";

import React, { useState, useEffect } from "react";
import { Loader2, X, UserPlus, Mail, Lock, Building, Shield, BookOpen, Tag } from "lucide-react";
import { collection, getDocs, query, orderBy, onSnapshot } from "firebase/firestore";
import { db } from "@/lib/firebase";

type Role = "staff" | "lecturer";

const ROLES: { value: Role; label: string; description: string; icon: React.ReactNode; color: string }[] = [
  {
    value: "staff",
    label: "Campus Staff",
    description: "Maintenance, IT, Cafeteria, etc.",
    icon: <Shield size={16} />,
    color: "emerald",
  },
  {
    value: "lecturer",
    label: "Lecturer",
    description: "Teaching staff & academics",
    icon: <BookOpen size={16} />,
    color: "blue",
  },
];

const LECTURER_CATALOGS = [
  { value: "Electrical Engineering Lecturers", department: "Electrical Engineering" },
  { value: "Mechanical Engineering Lecturers", department: "Mechanical Engineering" },
  { value: "Applied Science Lecturers", department: "Applied Science" },
  { value: "Social Sciences Lecturers", department: "Social Sciences" },
  { value: "Computer Science Lecturers", department: "Computer Science Engineering" },
  { value: "Software Engineering Lecturers", department: "Software Engineering" },
  { value: "Civil Engineering Lecturers", department: "Civil Engineering" },
  { value: "Water Resources Engineering Lecturers", department: "Water Resources Engineering" },
  { value: "Architecture Lecturers", department: "Architecture" },
];

export default function AddStaffModal({ onClose }: { onClose: () => void }) {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [assignment, setAssignment] = useState(""); // catalog for staff
  const [lecturerCategory, setLecturerCategory] = useState("");
  const [role, setRole] = useState<Role>("staff");

  const [staffCatalogs, setStaffCatalogs] = useState<{ id: string; name: string }[]>([]);

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Fetch staff catalogs in real-time
  useEffect(() => {
    const q = query(collection(db, "staffCatalogs"), orderBy("name", "asc"));
    const unsub = onSnapshot(q, (snap) => {
      setStaffCatalogs(snap.docs.map(d => ({ id: d.id, name: d.data().name })));
    });
    return () => unsub();
  }, []);

  // Reset assignment when role changes
  const handleRoleChange = (r: Role) => {
    setRole(r);
    setAssignment("");
    setLecturerCategory("");
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const payload: Record<string, string> = { name, email, password, role };

      if (role === "lecturer") {
        const selectedCatalog = LECTURER_CATALOGS.find((item) => item.value === lecturerCategory);
        payload.department = selectedCatalog?.department || "";
        payload.lecturerCategory = lecturerCategory;
      } else {
        payload.staffCatalog = assignment;
        // Store catalog name in department field too for display compatibility
        payload.department = assignment;
      }

      const res = await fetch("/api/users/create", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      const data = await res.json();
      if (!res.ok) throw new Error(data.error || "Failed to create account");

      onClose();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const assignmentOptions = staffCatalogs;
  const assignmentEmptyHint = "Add staff catalogs first from the Staff Catalogs button!";

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm animate-in fade-in">
      <div className="bg-[#111111] border border-[#2A2A2A] rounded-[2rem] w-full max-w-lg overflow-y-auto max-h-[90vh] shadow-2xl relative">

        {/* Header */}
        <div className="p-6 border-b border-[#2A2A2A] flex items-center justify-between bg-[#0A0A0A] sticky top-0 z-10">
          <div>
            <h2 className="text-xl font-black text-white tracking-wide flex items-center gap-3">
              <div className="p-2 bg-[#D4AF37]/10 rounded-xl">
                <UserPlus size={18} className="text-[#D4AF37]" />
              </div>
              Add New Member
            </h2>
            <p className="text-xs text-stone-500 mt-1 ml-11">
              {role === "lecturer" ? "Create a lecturer account under a lecturer catalog" : "Create a staff account under a service catalog"}
            </p>
          </div>
          <button onClick={onClose} className="p-2 rounded-xl text-stone-500 hover:text-white hover:bg-white/5 transition-all">
            <X size={18} />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-5">
          {error && (
            <div className="p-3 rounded-xl bg-rose-500/10 border border-rose-500/20 text-rose-400 text-xs font-medium">
              {error}
            </div>
          )}

          {/* Role Selector */}
          <div className="space-y-2">
            <label className="text-[10px] font-black uppercase tracking-widest text-stone-500">Account Type</label>
            <div className="grid grid-cols-2 gap-3">
              {ROLES.map((r) => (
                <button
                  key={r.value}
                  type="button"
                  onClick={() => handleRoleChange(r.value)}
                  className={`p-4 rounded-2xl border text-left transition-all ${
                    role === r.value
                      ? r.color === "emerald"
                        ? "border-emerald-500 bg-emerald-500/10"
                        : "border-blue-500 bg-blue-500/10"
                      : "border-[#2A2A2A] bg-[#0A0A0A] hover:border-[#3A3A3A]"
                  }`}
                >
                  <div className={`flex items-center gap-2 font-bold text-sm mb-1 ${
                    role === r.value
                      ? r.color === "emerald" ? "text-emerald-400" : "text-blue-400"
                      : "text-stone-400"
                  }`}>
                    {r.icon}
                    {r.label}
                  </div>
                  <p className="text-[10px] text-stone-600 leading-tight">{r.description}</p>
                </button>
              ))}
            </div>
          </div>

          {/* Full Name */}
          <div className="space-y-1.5">
            <label className="text-[10px] font-black uppercase tracking-widest text-stone-500">Full Name</label>
            <input
              type="text"
              required
              value={name}
              onChange={(e) => setName(e.target.value)}
              className="w-full bg-[#0A0A0A] border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white placeholder-stone-700 focus:outline-none focus:border-[#D4AF37] transition-colors"
              placeholder={role === "lecturer" ? "Dr. Jane Smith" : "John Doe"}
            />
          </div>

          {/* Email */}
          <div className="space-y-1.5">
            <label className="text-[10px] font-black uppercase tracking-widest text-stone-500">Email Address</label>
            <div className="relative">
              <Mail size={15} className="absolute left-4 top-1/2 -translate-y-1/2 text-stone-600" />
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full bg-[#0A0A0A] border border-[#2A2A2A] rounded-xl pl-11 pr-4 py-3 text-sm text-white placeholder-stone-700 focus:outline-none focus:border-[#D4AF37] transition-colors"
                placeholder={role === "lecturer" ? "lecturer@astu.edu.et" : "staff@astu.edu.et"}
              />
            </div>
          </div>

          {/* Password */}
          <div className="space-y-1.5">
            <label className="text-[10px] font-black uppercase tracking-widest text-stone-500">Temporary Password</label>
            <div className="relative">
              <Lock size={15} className="absolute left-4 top-1/2 -translate-y-1/2 text-stone-600" />
              <input
                type="password"
                required
                minLength={6}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full bg-[#0A0A0A] border border-[#2A2A2A] rounded-xl pl-11 pr-4 py-3 text-sm text-white placeholder-stone-700 focus:outline-none focus:border-[#D4AF37] transition-colors"
                placeholder="Min. 6 characters"
              />
            </div>
          </div>

          {role === "staff" && (
            <div className="space-y-1.5">
              <label className="text-[10px] font-black uppercase tracking-widest text-stone-500 flex items-center gap-2">
                <Tag size={12} />
                Staff Catalog
              </label>
              <div className="relative">
                <Tag size={15} className="absolute left-4 top-1/2 -translate-y-1/2 text-stone-600" />
                <select
                  required
                  value={assignment}
                  onChange={(e) => setAssignment(e.target.value)}
                  className="w-full bg-[#0A0A0A] border border-[#2A2A2A] rounded-xl pl-11 pr-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-colors appearance-none"
                >
                  <option value="">Select Catalog</option>
                  {assignmentOptions.map((opt) => (
                    <option key={opt.id} value={opt.name}>{opt.name}</option>
                  ))}
                </select>
                {assignmentOptions.length === 0 && (
                  <p className="text-[9px] text-amber-500 font-bold mt-1 ml-1 uppercase">{assignmentEmptyHint}</p>
                )}
              </div>
            </div>
          )}

          {/* Lecturer-only: Lecturer Category */}
          {role === "lecturer" && (
            <div className="space-y-1.5">
              <label className="text-[10px] font-black uppercase tracking-widest text-stone-500 flex items-center gap-2">
                <BookOpen size={12} />
                Lecturer Catalog
              </label>
              <div className="relative">
                <Building size={15} className="absolute left-4 top-1/2 -translate-y-1/2 text-stone-600" />
                <select
                  required
                  value={lecturerCategory}
                  onChange={(e) => setLecturerCategory(e.target.value)}
                  className="w-full bg-[#0A0A0A] border border-[#2A2A2A] rounded-xl pl-11 pr-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-colors appearance-none"
                >
                  <option value="">Select Lecturer Catalog</option>
                  {LECTURER_CATALOGS.map((catalog) => (
                    <option key={catalog.value} value={catalog.value}>{catalog.value}</option>
                  ))}
                </select>
              </div>
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full mt-2 bg-[#D4AF37] text-[#0A0A0A] py-4 rounded-xl font-black uppercase tracking-widest text-sm hover:bg-[#b08d2c] transition-all flex items-center justify-center gap-2 disabled:opacity-50 disabled:cursor-not-allowed shadow-lg shadow-yellow-900/20"
          >
            {loading ? (
              <Loader2 size={18} className="animate-spin" />
            ) : (
              <>
                <UserPlus size={16} />
                Create {role === "lecturer" ? "Lecturer" : "Staff"} Account
              </>
            )}
          </button>
        </form>
      </div>
    </div>
  );
}
