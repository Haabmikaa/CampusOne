"use client";

import React, { useEffect, useState } from "react";
import { collection, limit, onSnapshot, orderBy, query, Timestamp, where } from "firebase/firestore";
import { db } from "@/lib/firebase";
import {
  Users,
  Shield,
  Megaphone,
  TrendingUp,
  MessageSquare,
  CheckCircle,
  Clock,
} from "lucide-react";

import { Sidebar } from "@/components/Sidebar";

import { useAuth } from "@/context/AuthContext";

interface RecentActivityItem {
  id: string;
  type: "broadcast" | "complaint";
  title?: string;
  audience?: string;
  priority?: string;
  status?: string;
  createdAt?: Timestamp | Date | null;
}

export default function Dashboard() {
  const { user, role } = useAuth();
  const [stats, setStats] = useState({
    totalUsers: 0,
    totalStaff: 0,
    totalBroadcasts: 0,
    myAssigned: 0,
    myResolved: 0,
  });
  const [recentData, setRecentData] = useState<RecentActivityItem[]>([]);

  useEffect(() => {
    if (!role) return;

    // Admin System Metrics
    const unsubUsers = onSnapshot(collection(db, "users"), (snap) => {
      let users = 0;
      let staff = 0;
      snap.docs.forEach((d) => {
        users++;
        if (d.data().role === "staff") staff++;
      });
      setStats((s) => ({ ...s, totalUsers: users, totalStaff: staff }));
    });

    // Broadcasts (Recent)
    const unsubBroadcastStats = onSnapshot(collection(db, "broadcasts"), (snap) => {
      setStats((s) => ({ ...s, totalBroadcasts: snap.docs.length }));
    });

    const qBroadcasts = query(collection(db, "broadcasts"), orderBy("createdAt", "desc"), limit(5));
    const unsubBroadcasts = onSnapshot(qBroadcasts, (snap) => {
      if (role === 'admin') {
        setRecentData(snap.docs.map(d => ({ id: d.id, ...d.data(), type: 'broadcast' })));
      }
    });

    // Staff Specific Metrics (Complaints)
    let unsubComplaints = () => {};
    if (role === 'staff' && user?.uid) {
      const qMyComplaints = query(collection(db, "complaints"), where("assignedTo", "==", user.uid));
      unsubComplaints = onSnapshot(qMyComplaints, (snap) => {
        let assigned = 0;
        let resolved = 0;
        const complaints = snap.docs.map(d => {
          const data = d.data();
          assigned++;
          if (data.status === 'resolved' || data.status === 'closed') resolved++;
          return { id: d.id, ...data, type: 'complaint' };
        });
        setStats(s => ({ ...s, myAssigned: assigned, myResolved: resolved }));
        setRecentData(complaints.slice(0, 5));
      });
    }

    return () => {
      unsubUsers();
      unsubBroadcastStats();
      unsubBroadcasts();
      unsubComplaints();
    };
  }, [role, user?.uid]);

  return (
    <div className="flex min-h-screen bg-[#0A0A0A] text-[#f3f4f6]">
      <Sidebar />
      <main className="flex-1 ml-[18rem] p-10 pb-20 space-y-10 animate-in fade-in duration-700">
      {/* Header */}
      <div>
        <h1 className="text-5xl font-black text-white uppercase italic tracking-tighter flex items-center gap-4">
          <TrendingUp size={40} className="text-[#D4AF37]" />
          {role === 'staff' ? 'Staff Workspace' : 'Dashboard Overview'}
        </h1>
        <p className="text-stone-400 mt-2 text-sm font-medium">
          {role === 'staff' ? 'Manage your assigned campus tasks and resolutions.' : 'CampusOne System Metrics and Activity'}
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {role === 'admin' ? (
          <>
            <div className="bg-[#161616] border border-[#2A2A2A] rounded-[2rem] p-8 backdrop-blur-xl">
              <Users size={24} className="text-[#D4AF37] mb-4" />
              <p className="text-3xl font-black text-white">{stats.totalUsers}</p>
              <p className="text-[10px] font-black text-stone-400 uppercase tracking-widest mt-1">Total Users</p>
            </div>
            <div className="bg-[#161616] border border-[#2A2A2A] rounded-[2rem] p-8 backdrop-blur-xl">
              <Shield size={24} className="text-emerald-400 mb-4" />
              <p className="text-3xl font-black text-white">{stats.totalStaff}</p>
              <p className="text-[10px] font-black text-stone-400 uppercase tracking-widest mt-1">Total Staff</p>
            </div>
            <div className="bg-[#161616] border border-[#2A2A2A] rounded-[2rem] p-8 backdrop-blur-xl">
              <Megaphone size={24} className="text-amber-400 mb-4" />
              <p className="text-3xl font-black text-white">{stats.totalBroadcasts}</p>
              <p className="text-[10px] font-black text-stone-400 uppercase tracking-widest mt-1">Broadcasts Sent</p>
            </div>
          </>
        ) : (
          <>
            <div className="bg-[#161616] border border-[#2A2A2A] rounded-[2rem] p-8 backdrop-blur-xl border-l-4 border-l-blue-500">
              <MessageSquare size={24} className="text-blue-500 mb-4" />
              <p className="text-3xl font-black text-white">{stats.myAssigned}</p>
              <p className="text-[10px] font-black text-stone-400 uppercase tracking-widest mt-1">Total Assigned</p>
            </div>
            <div className="bg-[#161616] border border-[#2A2A2A] rounded-[2rem] p-8 backdrop-blur-xl border-l-4 border-l-green-500">
              <CheckCircle size={24} className="text-green-500 mb-4" />
              <p className="text-3xl font-black text-white">{stats.myResolved}</p>
              <p className="text-[10px] font-black text-stone-400 uppercase tracking-widest mt-1">Resolved Tasks</p>
            </div>
            <div className="bg-[#161616] border border-[#2A2A2A] rounded-[2rem] p-8 backdrop-blur-xl border-l-4 border-l-amber-500">
              <Clock size={24} className="text-amber-500 mb-4" />
              <p className="text-3xl font-black text-white">{stats.myAssigned - stats.myResolved}</p>
              <p className="text-[10px] font-black text-stone-400 uppercase tracking-widest mt-1">Active Pending</p>
            </div>
          </>
        )}
      </div>

      {/* Recent Activity */}
      <div>
        <h2 className="text-xl font-black text-white uppercase tracking-widest mb-6">
          {role === 'staff' ? 'Your Recent Assignments' : 'Recent System Activity'}
        </h2>
        <div className="bg-[#161616] border border-[#2A2A2A] rounded-[2.5rem] overflow-hidden backdrop-blur-xl">
          <table className="w-full">
            <thead>
              <tr className="border-b border-[#2A2A2A]">
                <th className="text-left px-8 py-5 text-[10px] font-black text-stone-400 uppercase tracking-widest">
                  {role === 'staff' ? 'Complaint Title' : 'Broadcast Title'}
                </th>
                <th className="text-left px-4 py-5 text-[10px] font-black text-stone-400 uppercase tracking-widest">
                  {role === 'staff' ? 'Priority' : 'Topic'}
                </th>
                <th className="text-left px-4 py-5 text-[10px] font-black text-stone-400 uppercase tracking-widest">Status / Date</th>
              </tr>
            </thead>
            <tbody>
              {recentData.map((item) => (
                <tr key={item.id} className="border-b border-white/[0.02] hover:bg-white/[0.01] transition-all">
                  <td className="px-8 py-5">
                    <p className="font-black text-white text-sm">{item.title}</p>
                  </td>
                  <td className="px-4 py-5">
                    <span className={`text-[10px] font-black uppercase tracking-widest px-3 py-1.5 rounded-full ${
                      item.type === 'broadcast' ? 'bg-blue-500/10 text-blue-400' : 
                      item.priority === 'Urgent' ? 'bg-red-500/10 text-red-500' : 'bg-orange-500/10 text-orange-500'
                    }`}>
                      {item.type === 'broadcast' ? (item.audience || "all") : item.priority}
                    </span>
                  </td>
                  <td className="px-4 py-5">
                    <span className="text-xs text-stone-400">
                      {item.type === 'broadcast' ? 
                        (item.createdAt?.toDate ? item.createdAt.toDate().toLocaleDateString() : '—') :
                        item.status.toUpperCase().replace('_', ' ')}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {recentData.length === 0 && (
            <div className="py-20 text-center text-stone-500">
              <Megaphone size={40} className="mx-auto mb-4 opacity-30" />
              <p className="font-black uppercase tracking-widest text-sm">No recent activity</p>
            </div>
          )}
        </div>
      </div>
      </main>
    </div>
  );
}
