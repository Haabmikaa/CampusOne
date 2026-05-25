"use client";

import React, { useEffect, useState } from "react";
import { Sidebar } from "@/components/Sidebar";
import { collection, query, onSnapshot, orderBy, where } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { 
  Layout, 
  Clock, 
  CheckCircle, 
  RotateCcw, 
  User, 
  Loader2, 
  Search,
  Filter
} from "lucide-react";
import { useAuth } from "@/context/AuthContext";

interface Complaint {
  id: string;
  title: string;
  status: string;
  assignedTo?: string;
  priority: string;
  category: string;
  createdAt: any;
}

export default function TaskBoardPage() {
  const { role } = useAuth();
  const [complaints, setComplaints] = useState<Complaint[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  useEffect(() => {
    const q = query(collection(db, "complaints"), orderBy("createdAt", "desc"));
    const unsub = onSnapshot(q, (snap) => {
      setComplaints(snap.docs.map(d => ({ id: d.id, ...d.data() } as Complaint)));
      setLoading(false);
    });
    return () => unsub();
  }, []);

  if (role !== 'admin' && !loading) {
    return (
      <div className="flex min-h-screen bg-[#0A0A0A] items-center justify-center">
        <p className="text-stone-500 font-black uppercase tracking-widest">Unauthorized Access</p>
      </div>
    );
  }

  const columns = [
    { id: "pending", label: "Pending", icon: Clock, color: "text-stone-400", border: "border-stone-500/20" },
    { id: "in_review", label: "In Progress", icon: RotateCcw, color: "text-amber-500", border: "border-amber-500/20" },
    { id: "resolved", label: "Resolved", icon: CheckCircle, color: "text-emerald-500", border: "border-emerald-500/20" },
  ];

  const getFilteredTasks = (status: string) => {
    return complaints.filter(c => 
      c.status === status && 
      c.title.toLowerCase().includes(search.toLowerCase())
    );
  };

  return (
    <div className="flex min-h-screen bg-[#0A0A0A] text-[#f3f4f6]">
      <Sidebar />
      <main className="flex-1 ml-[18rem] p-10 flex flex-col h-screen">
        
        {/* Header */}
        <div className="flex items-center justify-between mb-10">
          <div>
            <h1 className="text-4xl font-black text-white uppercase italic tracking-tighter flex items-center gap-4">
              <Layout size={32} className="text-[#D4AF37]" />
              Task Monitoring Board
            </h1>
            <p className="text-stone-500 text-xs font-black uppercase tracking-[0.3em] mt-1">Real-time resolution tracking</p>
          </div>
          
          <div className="relative w-80 group">
            <Search size={16} className="absolute left-4 top-1/2 -translate-y-1/2 text-stone-600 group-focus-within:text-[#D4AF37] transition-colors" />
            <input
              type="text"
              placeholder="Search tasks..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full bg-[#161616] border border-[#2A2A2A] rounded-2xl pl-12 pr-4 py-3.5 text-xs text-white focus:outline-none focus:border-[#D4AF37] transition-all"
            />
          </div>
        </div>

        {loading ? (
          <div className="flex-1 flex items-center justify-center">
            <Loader2 className="animate-spin text-stone-500" size={32} />
          </div>
        ) : (
          <div className="flex-1 grid grid-cols-3 gap-6 overflow-hidden">
            {columns.map(col => (
              <div key={col.id} className="flex flex-col gap-4 min-h-0">
                <div className="flex items-center justify-between px-2">
                  <div className="flex items-center gap-3">
                    <col.icon size={16} className={col.color} />
                    <h2 className="text-xs font-black text-white uppercase tracking-widest">{col.label}</h2>
                    <span className="bg-white/5 text-[9px] font-black text-stone-500 px-2 py-0.5 rounded-full border border-white/10">
                      {getFilteredTasks(col.id).length}
                    </span>
                  </div>
                </div>

                <div className={`flex-1 bg-[#161616]/30 border-t-2 ${col.border} rounded-t-3xl p-4 space-y-4 overflow-y-auto custom-scrollbar`}>
                  {getFilteredTasks(col.id).map(task => (
                    <div 
                      key={task.id} 
                      className="bg-[#161616] border border-[#2A2A2A] rounded-2xl p-5 hover:border-[#D4AF37]/30 transition-all group shadow-lg"
                    >
                      <div className="flex items-start justify-between mb-3">
                        <span className={`text-[8px] font-black px-2 py-1 rounded uppercase tracking-widest ${
                          task.priority === 'Urgent' ? 'bg-red-500/10 text-red-500' :
                          task.priority === 'High' ? 'bg-orange-500/10 text-orange-500' :
                          'bg-blue-500/10 text-blue-500'
                        }`}>
                          {task.priority}
                        </span>
                        <span className="text-[8px] font-black text-stone-600 uppercase tracking-widest">{task.category}</span>
                      </div>
                      
                      <h3 className="text-xs font-bold text-white mb-4 line-clamp-2 leading-relaxed group-hover:text-[#D4AF37] transition-colors">
                        {task.title}
                      </h3>

                      <div className="pt-4 border-t border-white/5 flex items-center justify-between">
                        <div className="flex items-center gap-2">
                          <div className="w-6 h-6 rounded-lg bg-stone-900 flex items-center justify-center">
                            <User size={12} className={task.assignedTo ? "text-emerald-500" : "text-stone-700"} />
                          </div>
                          <p className="text-[9px] font-black text-stone-500 uppercase tracking-widest truncate max-w-[80px]">
                            {task.assignedTo ? "Assigned" : "Unassigned"}
                          </p>
                        </div>
                        <p className="text-[8px] font-black text-stone-700 uppercase">
                          {task.createdAt?.toDate ? task.createdAt.toDate().toLocaleDateString() : '—'}
                        </p>
                      </div>
                    </div>
                  ))}

                  {getFilteredTasks(col.id).length === 0 && (
                    <div className="h-32 flex items-center justify-center border border-dashed border-[#2A2A2A] rounded-2xl">
                      <p className="text-[10px] font-black text-stone-700 uppercase tracking-widest">No Tasks</p>
                    </div>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </main>
    </div>
  );
}
