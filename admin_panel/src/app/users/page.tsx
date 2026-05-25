"use client";

import React, { useEffect, useState } from "react";
import {
  collection,
  query,
  onSnapshot,
  doc,
  updateDoc,
  deleteDoc,
  orderBy,
  Timestamp,
  where,
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import {
  Users,
  Search,
  Shield,
  ShieldOff,
  Trash2,
  Mail,
  Loader2,
  UserPlus,
  Building,
  Eye,
  X,
  MessageSquare,
} from "lucide-react";
import AddStaffModal from "./AddStaffModal";
import DepartmentModal from "./DepartmentModal";
import StaffCatalogModal from "./StaffCatalogModal";
import { Sidebar } from "@/components/Sidebar";

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
  department?: string;
  studentId?: string;
  cohort?: string;
  yearSemester?: string;
  section?: string;
  studentGroup?: string;
  isBlocked?: boolean;
  createdAt?: Timestamp | Date | null;
}

interface StudentComplaint {
  id: string;
  title: string;
  category?: string;
  priority?: string;
  status?: string;
  createdAt?: Timestamp | Date | null;
}

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [filter, setFilter] = useState<"all" | "student" | "staff" | "admin">("all");
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [isAddStaffOpen, setIsAddStaffOpen] = useState(false);
  const [isDeptModalOpen, setIsDeptModalOpen] = useState(false);
  const [isStaffCatalogOpen, setIsStaffCatalogOpen] = useState(false);
  const [selectedStudent, setSelectedStudent] = useState<User | null>(null);
  const [studentComplaints, setStudentComplaints] = useState<StudentComplaint[]>([]);
  const selectedStudentId = selectedStudent?.id;
  const selectedStudentRole = selectedStudent?.role;

  useEffect(() => {
    const q = query(collection(db, "users"), orderBy("createdAt", "desc"));
    const unsub = onSnapshot(q, (snap) => {
      const base = snap.docs.map((d) => ({
        id: d.id,
        name: d.data().name || "Unknown",
        email: d.data().email || "—",
        role: d.data().role || "student",
        department: d.data().department || "",
        studentId: d.data().studentId || "",
        cohort: d.data().cohort || "",
        yearSemester: d.data().yearSemester || "",
        section: d.data().section || "",
        studentGroup: d.data().studentGroup || "",
        isBlocked: d.data().isBlocked || false,
        createdAt: d.data().createdAt,
      })) as User[];

      setUsers(base);
      setLoading(false);
    });
    return () => unsub();
  }, []);

  useEffect(() => {
    if (!selectedStudentId || selectedStudentRole !== "student") {
      return;
    }

    const q = query(
      collection(db, "complaints"),
      where("studentId", "==", selectedStudentId),
    );

    const unsub = onSnapshot(q, (snap) => {
      const complaints = snap.docs
        .map((d) => ({ id: d.id, ...d.data() })) as StudentComplaint[];

      complaints.sort((a, b) => {
        const aTime = a.createdAt?.toDate ? a.createdAt.toDate().getTime() : 0;
        const bTime = b.createdAt?.toDate ? b.createdAt.toDate().getTime() : 0;
        return bTime - aTime;
      });

      setStudentComplaints(complaints);
    });

    return () => unsub();
  }, [selectedStudentId, selectedStudentRole]);

  const handleBlock = async (u: User) => {
    setActionLoading(u.id);
    try {
      await updateDoc(doc(db, "users", u.id), { isBlocked: !u.isBlocked });
    } finally {
      setActionLoading(null);
    }
  };

  const handleDelete = async (u: User) => {
    const confirmed = window.confirm(
      `⚠️ PERMANENTLY delete ${u.name}?\n\nThis cannot be undone. Type "DELETE" in the next prompt to confirm.`
    );
    if (!confirmed) return;
    const typed = window.prompt('Type "DELETE" to confirm:');
    if (typed !== "DELETE") return;

    setActionLoading(u.id);
    try {
      await deleteDoc(doc(db, "users", u.id));
    } finally {
      setActionLoading(null);
    }
  };

  const filtered = users.filter((u) => {
    const matchSearch =
      u.name.toLowerCase().includes(search.toLowerCase()) ||
      u.email.toLowerCase().includes(search.toLowerCase());
    if (!matchSearch) return false;
    if (filter !== "all" && u.role !== filter) return false;
    return true;
  });

  const formatDate = (ts?: Timestamp | Date | null) => {
    if (!ts) return "—";
    const d = ts.toDate ? ts.toDate() : new Date(ts);
    return d.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" });
  };

  const totalUsers = users.length;
  const totalStaff = users.filter((u) => u.role === "staff").length;
  const totalAdmins = users.filter((u) => u.role === "admin").length;
  const openStudentDetails = (user: User) => {
    if (user.role === "student") {
      setStudentComplaints([]);
      setSelectedStudent(user);
    }
  };

  const formatStatus = (value?: string) =>
    (value || "pending").replace(/_/g, " ");

  return (
    <div className="flex min-h-screen bg-[#0A0A0A] text-[#f3f4f6]">
      <Sidebar />
      <main className="flex-1 ml-[18rem] p-10 pb-20 space-y-10 animate-in fade-in duration-700">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-5xl font-black text-white uppercase italic tracking-tighter flex items-center gap-4">
            <Users size={40} className="text-[#D4AF37]" />
            Users
          </h1>
          <p className="text-stone-400 mt-2 text-sm font-medium">
            Manage students, staff, and system access.
          </p>
        </div>
        <div className="flex gap-3">
          <button
            onClick={() => setIsStaffCatalogOpen(true)}
            className="flex items-center gap-2 bg-[#161616] border border-[#2A2A2A] text-stone-400 px-6 py-3 rounded-xl font-black uppercase tracking-widest text-sm hover:text-white transition-colors"
          >
            <Users size={18} />
            Staff Catalogs
          </button>
          <button
            onClick={() => setIsDeptModalOpen(true)}
            className="flex items-center gap-2 bg-[#161616] border border-[#2A2A2A] text-stone-400 px-6 py-3 rounded-xl font-black uppercase tracking-widest text-sm hover:text-white transition-colors"
          >
            <Building size={18} />
            Departments
          </button>
          <button
            onClick={() => setIsAddStaffOpen(true)}
            className="flex items-center gap-2 bg-[#D4AF37] text-[#0A0A0A] px-6 py-3 rounded-xl font-black uppercase tracking-widest text-sm hover:bg-[#b08d2c] transition-colors"
          >
            <UserPlus size={18} />
            Add Member
          </button>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-6">
        {[
          { label: "Total Users", value: totalUsers, icon: Users, color: "text-[#D4AF37]" },
          { label: "Total Staff", value: totalStaff, icon: Shield, color: "text-emerald-400" },
          { label: "Admins", value: totalAdmins, icon: Shield, color: "text-amber-400" },
        ].map((s) => (
          <div key={s.label} className="bg-[#161616] border border-[#2A2A2A] rounded-[2rem] p-8 backdrop-blur-xl">
            <s.icon size={24} className={`${s.color} mb-4`} />
            <p className="text-3xl font-black text-white">{s.value}</p>
            <p className="text-[10px] font-black text-stone-400 uppercase tracking-widest mt-1">{s.label}</p>
          </div>
        ))}
      </div>

      {/* Search & Filters */}
      <div className="flex flex-col md:flex-row gap-4">
        <div className="relative flex-1 group">
          <Search size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-stone-400 group-focus-within:text-[#D4AF37] transition-colors" />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search by name or email..."
            className="terminal-input w-full pl-12"
          />
        </div>
        <div className="flex gap-2">
          {(["all", "student", "staff", "admin"] as const).map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={`px-5 py-3 rounded-xl text-[11px] font-black uppercase tracking-widest transition-all ${
                filter === f
                  ? "bg-[#D4AF37] text-[#0A0A0A]"
                  : "bg-[#161616] border border-[#2A2A2A] text-stone-400 hover:text-white"
              }`}
            >
              {f}
            </button>
          ))}
        </div>
      </div>

      {loading ? (
        <div className="h-64 flex items-center justify-center">
          <Loader2 className="animate-spin text-stone-500" size={32} />
        </div>
      ) : (
        <div className="bg-[#161616] border border-[#2A2A2A] rounded-[2.5rem] overflow-hidden backdrop-blur-xl">
          <table className="w-full">
            <thead>
              <tr className="border-b border-[#2A2A2A]">
                <th className="text-left px-8 py-5 text-[10px] font-black text-stone-400 uppercase tracking-widest">User</th>
                <th className="text-left px-4 py-5 text-[10px] font-black text-stone-400 uppercase tracking-widest">Role</th>
                <th className="text-left px-4 py-5 text-[10px] font-black text-stone-400 uppercase tracking-widest">Dept / Catalog</th>
                <th className="text-left px-4 py-5 text-[10px] font-black text-stone-400 uppercase tracking-widest">Joined</th>
                <th className="text-right px-8 py-5 text-[10px] font-black text-stone-400 uppercase tracking-widest">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((u) => (
                <tr
                  key={u.id}
                  onClick={() => openStudentDetails(u)}
                  className={`border-b border-white/[0.02] transition-all group ${
                    u.role === "student" ? "cursor-pointer hover:bg-white/[0.01]" : "hover:bg-white/[0.01]"
                  } ${
                    u.isBlocked ? "opacity-50" : ""
                  }`}
                >
                  <td className="px-8 py-5">
                    <div className="flex items-center gap-4">
                      <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-[#D4AF37] to-amber-700 flex items-center justify-center text-[#0A0A0A] font-black text-xs">
                        {u.name.charAt(0).toUpperCase()}
                      </div>
                      <div>
                        <p className="font-black text-white text-sm flex items-center gap-2">
                          {u.name}
                          {u.isBlocked && (
                            <span className="text-[9px] font-black text-rose-400 bg-rose-500/10 px-2 py-0.5 rounded-full uppercase">
                              Blocked
                            </span>
                          )}
                        </p>
                        <p className="text-xs text-stone-400 flex items-center gap-1 mt-0.5">
                          <Mail size={10} className="text-[#D4AF37]" /> {u.email}
                        </p>
                      </div>
                    </div>
                  </td>
                  <td className="px-4 py-5">
                    <span
                      className={`text-[10px] font-black uppercase tracking-widest px-3 py-1.5 rounded-full ${
                        u.role === "admin"
                          ? "bg-amber-500/10 text-amber-400"
                          : u.role === "staff"
                          ? "bg-emerald-500/10 text-emerald-400"
                          : "bg-stone-900 text-stone-400"
                      }`}
                    >
                      {u.role.toUpperCase()}
                    </span>
                  </td>
                  <td className="px-4 py-5">
                    <div className="flex flex-col gap-0.5">
                      <span className="text-xs text-stone-300 font-semibold">{u.department || "—"}</span>
                      <span className="text-[9px] uppercase tracking-widest text-stone-600">
                        {u.role === "lecturer" ? "Department" : u.role === "staff" ? "Staff Catalog" : ""}
                      </span>
                    </div>
                  </td>
                  <td className="px-4 py-5">
                    <span className="text-xs text-stone-400">{formatDate(u.createdAt)}</span>
                  </td>
                  <td className="px-8 py-5">
                    <div className="flex items-center justify-end gap-2">
                      {u.role === "student" && (
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            openStudentDetails(u);
                          }}
                          title="View Student"
                          className="p-2.5 rounded-xl bg-sky-500/10 text-sky-400 hover:bg-sky-500/20 transition-all border border-[#2A2A2A]"
                        >
                          <Eye size={14} />
                        </button>
                      )}
                      {u.role !== "admin" && (
                        <>
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              handleBlock(u);
                            }}
                            disabled={actionLoading === u.id}
                            title={u.isBlocked ? "Unblock" : "Block"}
                            className={`p-2.5 rounded-xl transition-all border border-[#2A2A2A] ${
                              u.isBlocked
                                ? "bg-emerald-500/10 text-emerald-400 hover:bg-emerald-500/20"
                                : "bg-amber-500/10 text-amber-400 hover:bg-amber-500/20"
                            }`}
                          >
                            {actionLoading === u.id ? (
                              <Loader2 size={14} className="animate-spin" />
                            ) : u.isBlocked ? (
                              <Shield size={14} />
                            ) : (
                              <ShieldOff size={14} />
                            )}
                          </button>
                          <button
                            onClick={(e) => {
                              e.stopPropagation();
                              handleDelete(u);
                            }}
                            title="Delete Account"
                            className="p-2.5 rounded-xl bg-rose-500/10 text-rose-400 hover:bg-rose-500/20 transition-all border border-[#2A2A2A]"
                          >
                            <Trash2 size={14} />
                          </button>
                        </>
                      )}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          {filtered.length === 0 && (
            <div className="py-20 text-center text-stone-500">
              <Users size={40} className="mx-auto mb-4 opacity-30" />
              <p className="font-black uppercase tracking-widest text-sm">No users found</p>
            </div>
          )}
        </div>
      )}

      {isAddStaffOpen && (
        <AddStaffModal onClose={() => setIsAddStaffOpen(false)} />
      )}
      {isDeptModalOpen && (
        <DepartmentModal onClose={() => setIsDeptModalOpen(false)} />
      )}
      {isStaffCatalogOpen && (
        <StaffCatalogModal onClose={() => setIsStaffCatalogOpen(false)} />
      )}
      {selectedStudent && (
        <div className="fixed inset-0 z-50 bg-black/70 backdrop-blur-sm">
          <div className="absolute inset-y-0 right-0 w-full max-w-2xl bg-[#111111] border-l border-[#2A2A2A] p-8 overflow-y-auto">
            <div className="flex items-start justify-between gap-4 mb-8">
              <div>
                <p className="text-[10px] font-black text-stone-500 uppercase tracking-[0.35em] mb-2">
                  Student Profile
                </p>
                <h2 className="text-3xl font-black text-white">{selectedStudent.name}</h2>
                <p className="text-sm text-stone-400 mt-2">{selectedStudent.email}</p>
              </div>
              <button
                onClick={() => setSelectedStudent(null)}
                className="p-3 rounded-xl bg-[#161616] border border-[#2A2A2A] text-stone-400 hover:text-white transition-colors"
              >
                <X size={18} />
              </button>
            </div>

            <div className="grid grid-cols-2 gap-4 mb-8">
              {[
                { label: "Student ID", value: selectedStudent.studentId || "—" },
                { label: "Department", value: selectedStudent.department || "—" },
                { label: "Year / Semester", value: selectedStudent.yearSemester || "—" },
                { label: "Cohort", value: selectedStudent.cohort || "—" },
                { label: "Section", value: selectedStudent.section || "—" },
                { label: "Group", value: selectedStudent.studentGroup || "—" },
              ].map((item) => (
                <div key={item.label} className="bg-[#161616] border border-[#2A2A2A] rounded-2xl p-5">
                  <p className="text-[10px] font-black text-stone-500 uppercase tracking-widest mb-2">
                    {item.label}
                  </p>
                  <p className="text-sm font-semibold text-white leading-relaxed">{item.value}</p>
                </div>
              ))}
            </div>

            <div className="bg-[#161616] border border-[#2A2A2A] rounded-[2rem] p-6">
              <div className="flex items-center justify-between gap-4 mb-6">
                <div>
                  <h3 className="text-lg font-black text-white flex items-center gap-3">
                    <MessageSquare size={18} className="text-[#D4AF37]" />
                    Complaints
                  </h3>
                  <p className="text-xs text-stone-500 mt-1">
                    {studentComplaints.length} total complaint{studentComplaints.length === 1 ? "" : "s"}
                  </p>
                </div>
              </div>

              <div className="space-y-4">
                {studentComplaints.length === 0 ? (
                  <div className="rounded-2xl border border-dashed border-[#2A2A2A] p-8 text-center text-stone-500">
                    No complaints submitted yet.
                  </div>
                ) : (
                  studentComplaints.map((complaint) => (
                    <div
                      key={complaint.id}
                      className="rounded-2xl border border-[#2A2A2A] bg-black/40 p-4"
                    >
                      <div className="flex items-start justify-between gap-4">
                        <div>
                          <p className="text-sm font-bold text-white">{complaint.title}</p>
                          <p className="text-[11px] uppercase tracking-widest text-stone-500 mt-2">
                            {complaint.category || "General"} • {complaint.priority || "Medium"}
                          </p>
                        </div>
                        <span className="rounded-full bg-blue-500/10 px-3 py-1 text-[10px] font-black uppercase tracking-widest text-blue-400">
                          {formatStatus(complaint.status)}
                        </span>
                      </div>
                      <p className="text-[11px] text-stone-500 mt-3">
                        Reported {formatDate(complaint.createdAt)}
                      </p>
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>
        </div>
      )}
      </main>
    </div>
  );
}
