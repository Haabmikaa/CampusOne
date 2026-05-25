"use client";

import React, { useEffect, useState } from "react";
import { Sidebar } from "@/components/Sidebar";
import { addDoc, collection, doc, getDocs, onSnapshot, orderBy, query, serverTimestamp, Timestamp, updateDoc, where } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { MessageSquare, Loader2, Clock, ShieldAlert, UserCheck } from "lucide-react";
import { useAuth } from "@/context/AuthContext";
import AssignStaffModal from "./AssignStaffModal";

interface ComplaintItem {
  id: string;
  title: string;
  description?: string;
  category?: string;
  createdAt?: Timestamp | Date | null;
  status?: string;
  priority?: string;
  assignedTo?: string;
  studentId?: string;
  mediaUrls?: string[];
}

interface StaffMember {
  id: string;
  name?: string;
}

export default function ComplaintsPage() {
  const { user, role } = useAuth();
  const [complaints, setComplaints] = useState<ComplaintItem[]>([]);
  const [staffMembers, setStaffMembers] = useState<StaffMember[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState("all");
  const [assigningId, setAssigningId] = useState<string | null>(null);

  useEffect(() => {
    // Fetch Staff Members for assignment in real-time
    const qStaff = query(collection(db, "users"), where("role", "==", "staff"));
    const unsubStaff = onSnapshot(qStaff, (snap) => {
      setStaffMembers(snap.docs.map(d => ({ id: d.id, ...d.data() } as StaffMember)));
    });

    // Fetch Complaints
    let q = query(collection(db, "complaints"), orderBy("createdAt", "desc"));
    
    // If staff, only show assigned to them
    if (role === 'staff') {
      q = query(
        collection(db, "complaints"), 
        where("assignedTo", "==", user?.uid),
        orderBy("createdAt", "desc")
      );
    }

    const unsub = onSnapshot(q, (snap) => {
      setComplaints(snap.docs.map(d => ({ id: d.id, ...d.data() })));
      setLoading(false);
    });
    return () => {
      unsubStaff();
      unsub();
    };
  }, [role, user?.uid]);

  const createStudentNotification = async (
    complaint: ComplaintItem,
    title: string,
    body: string,
  ) => {
    if (!complaint.studentId) return;

    await addDoc(collection(db, "users", complaint.studentId, "notifications"), {
      title,
      body,
      type: "complaint",
      isRead: false,
      referenceId: complaint.id,
      createdAt: serverTimestamp(),
    });
  };

  const handleUpdateStatus = async (complaint: ComplaintItem, newStatus: string) => {
    if (complaint.status === newStatus) return;

    try {
      await updateDoc(doc(db, "complaints", complaint.id), {
        status: newStatus,
        updatedAt: serverTimestamp()
      });

      const statusLabel = newStatus.replace("_", " ");
      await createStudentNotification(
        complaint,
        `Complaint ${statusLabel.replace(/\b\w/g, (char) => char.toUpperCase())}`,
        `Your complaint "${complaint.title}" is now ${statusLabel}.`,
      );
    } catch (e) {
      console.error(e);
      alert("Failed to update status");
    }
  };

  const handleAssignStaff = async (complaintId: string, staffId: string) => {
    try {
      const complaint = complaints.find((item) => item.id === complaintId);
      await updateDoc(doc(db, "complaints", complaintId), {
        assignedTo: staffId,
        status: "in_review", // Auto-move to in review when assigned
        updatedAt: serverTimestamp()
      });

      if (complaint) {
        await createStudentNotification(
          complaint,
          "Complaint In Review",
          `Your complaint "${complaint.title}" has been assigned and is now in review.`,
        );
      }
    } catch (e) {
      console.error(e);
      alert("Failed to assign staff");
    }
  };

  const filtered = complaints.filter(c => filter === "all" ? true : c.status === filter);

  if (loading) {
    return (
      <div className="flex min-h-screen bg-[#0A0A0A] text-[#f3f4f6]">
        <Sidebar />
        <main className="flex-1 ml-[18rem] flex items-center justify-center">
          <Loader2 className="animate-spin text-stone-500" size={32} />
        </main>
      </div>
    );
  }

  return (
    <div className="flex min-h-screen bg-[#0A0A0A] text-[#f3f4f6]">
      <Sidebar />
      <main className="flex-1 ml-[18rem] p-10 pb-20 space-y-10 animate-in fade-in duration-700">
        <div className="flex justify-between items-end mb-8">
          <div>
            <div className="flex items-center gap-3 mb-2">
              <div className="w-1.5 h-6 bg-red-500 rounded-full" />
              <p className="text-[10px] font-black text-stone-400 uppercase tracking-[0.4em]">
                {role === 'staff' ? 'My Assignments' : 'Campus Issues'}
              </p>
            </div>
            <h1 className="text-5xl font-black text-white uppercase italic tracking-tighter flex items-center gap-4">
              <MessageSquare size={40} className="text-red-500" />
              {role === 'staff' ? 'Assigned Tasks' : 'Complaints Log'}
            </h1>
          </div>
        </div>

        <div className="flex gap-2">
          {["all", "pending", "in_review", "resolved", "closed"].map((f) => (
            <button
              key={f}
              onClick={() => setFilter(f)}
              className={`px-5 py-3 rounded-xl text-[11px] font-black uppercase tracking-widest transition-all ${
                filter === f
                  ? "bg-red-500 text-white"
                  : "bg-[#161616] border border-[#2A2A2A] text-stone-400 hover:text-white"
              }`}
            >
              {f.replace('_', ' ')}
            </button>
          ))}
        </div>

        <div className="grid grid-cols-1 gap-6">
          {filtered.map(c => {
            const assignedStaff = staffMembers.find(s => s.id === c.assignedTo);
            
            return (
              <div key={c.id} className="bg-[#161616] border border-[#2A2A2A] rounded-2xl p-6 hover:border-red-500/30 transition-all group">
                <div className="flex justify-between items-start gap-6">
                  <div className="flex-1">
                    <div className="flex items-center gap-3 mb-3">
                      <span className={`px-2 py-1 text-[10px] uppercase font-black tracking-widest rounded ${
                        c.priority === 'Urgent' ? 'bg-red-500/20 text-red-500' :
                        c.priority === 'High' ? 'bg-orange-500/20 text-orange-500' :
                        'bg-blue-500/20 text-blue-500'
                      }`}>
                        {c.priority}
                      </span>
                      <span className="text-[10px] uppercase text-stone-500 font-bold tracking-widest">{c.category}</span>
                    </div>
                    
                    <h3 className="text-xl font-bold text-white mb-2 group-hover:text-red-500 transition-colors">{c.title}</h3>
                    <p className="text-sm text-stone-400 mb-6 leading-relaxed max-w-3xl">{c.description}</p>
                    
                    <div className="flex items-center gap-6">
                      {c.mediaUrls && c.mediaUrls.length > 0 && (
                        <div className="flex gap-2">
                          {c.mediaUrls.map((url: string, i: number) => (
                            <a key={i} href={url} target="_blank" rel="noreferrer" className="block transform hover:scale-105 transition-transform">
                              <img src={url} alt="Attachment" className="w-12 h-12 object-cover rounded-lg border border-[#2A2A2A]" />
                            </a>
                          ))}
                        </div>
                      )}
                      
                      <div className="flex flex-col gap-1">
                         <p className="text-[10px] text-stone-500 uppercase tracking-widest flex items-center gap-2">
                           <Clock size={10} />
                           Reported: {c.createdAt?.toDate ? c.createdAt.toDate().toLocaleString() : 'N/A'}
                         </p>
                         {assignedStaff && (
                           <p className="text-[10px] text-emerald-500 uppercase font-bold tracking-widest flex items-center gap-2">
                             <UserCheck size={10} />
                             Assigned to: {assignedStaff.name}
                           </p>
                         )}
                      </div>
                    </div>
                  </div>
                  
                  <div className="flex flex-col items-end gap-3 min-w-[200px]">
                    <div className="w-full space-y-2">
                      <p className="text-[9px] font-black text-stone-500 uppercase tracking-widest px-1">Status Control</p>
                      <select
                        value={c.status}
                        onChange={(e) => handleUpdateStatus(c, e.target.value)}
                        className={`w-full px-4 py-2.5 rounded-xl text-xs font-bold uppercase tracking-widest border border-[#2A2A2A] bg-black focus:outline-none focus:border-red-500 transition-colors ${
                          c.status === 'resolved' ? 'text-green-500' :
                          c.status === 'in_review' ? 'text-amber-500' :
                          'text-stone-400'
                        }`}
                      >
                        <option value="pending">Pending</option>
                        <option value="in_review">In Review</option>
                        <option value="resolved">Resolved</option>
                        <option value="closed">Closed</option>
                      </select>
                    </div>

                    {role === 'admin' && (
                      <div className="w-full space-y-2">
                        <p className="text-[9px] font-black text-stone-500 uppercase tracking-widest px-1">Assign Resolver</p>
                        <button
                          onClick={() => setAssigningId(c.id)}
                          className="w-full flex items-center justify-between px-4 py-3 rounded-xl text-xs font-bold uppercase tracking-widest border border-[#2A2A2A] bg-black hover:border-red-500 transition-all text-left"
                        >
                          <span className={assignedStaff ? "text-white" : "text-stone-500"}>
                            {assignedStaff ? assignedStaff.name : "Select Staff"}
                          </span>
                          <UserCheck size={14} className="text-red-500" />
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
          
          {filtered.length === 0 && (
            <div className="py-20 text-center text-stone-500 bg-[#111] border border-dashed border-[#2A2A2A] rounded-3xl">
              <ShieldAlert size={40} className="mx-auto mb-4 opacity-30" />
              <p className="font-black uppercase tracking-widest text-sm">No complaints found</p>
            </div>
          )}
        </div>
      </main>

      <AssignStaffModal
        isOpen={!!assigningId}
        onClose={() => setAssigningId(null)}
        staffMembers={staffMembers}
        onAssign={(staffId) => assigningId && handleAssignStaff(assigningId, staffId)}
      />
    </div>
  );
}
