"use client";

import React, { useEffect, useState } from "react";
import { Sidebar } from "@/components/Sidebar";
import { 
  HelpCircle, 
  MessageSquare, 
  CheckCircle, 
  Clock, 
  User,
  X,
  Send,
  Loader2,
  Trash2
} from "lucide-react";
import { 
  collection, 
  getDocs, 
  orderBy, 
  query, 
  doc, 
  updateDoc, 
  deleteDoc, 
  addDoc, 
  serverTimestamp,
  onSnapshot 
} from "firebase/firestore";
import { db } from "@/lib/firebase";

export default function SupportPage() {
  const [tickets, setTickets] = useState<any[]>([]);
  const [fetching, setFetching] = useState(true);
  const [selectedTicket, setSelectedTicket] = useState<any>(null);
  const [messages, setMessages] = useState<any[]>([]);
  const [reply, setReply] = useState("");
  const [sendingReply, setSendingReply] = useState(false);

  useEffect(() => {
    // Listen to all tickets
    const q = query(collection(db, "support_tickets"), orderBy("createdAt", "desc"));
    const unsub = onSnapshot(q, (snap) => {
      setTickets(snap.docs.map(d => ({ id: d.id, ...d.data() })));
      setFetching(false);
    });
    return () => unsub();
  }, []);

  useEffect(() => {
    if (!selectedTicket) {
      setMessages([]);
      return;
    }

    // Listen to messages for the selected ticket
    const msgsQuery = query(
      collection(db, "support_tickets", selectedTicket.id, "messages"),
      orderBy("timestamp", "asc")
    );
    
    const unsubMsgs = onSnapshot(msgsQuery, (snap) => {
      setMessages(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    });

    return () => unsubMsgs();
  }, [selectedTicket]);

  const resolveTicket = async (id: string) => {
    try {
      await updateDoc(doc(db, "support_tickets", id), { status: 'resolved' });
      setSelectedTicket(null);
    } catch (error) {
      alert("Error resolving ticket");
    }
  };

  const sendResponse = async () => {
    if (!reply.trim() || !selectedTicket) return;
    setSendingReply(true);
    try {
      // Add message to subcollection
      await addDoc(collection(db, "support_tickets", selectedTicket.id, "messages"), {
        sender: 'admin',
        text: reply.trim(),
        timestamp: serverTimestamp(),
      });

      // Update ticket status
      await updateDoc(doc(db, "support_tickets", selectedTicket.id), {
        status: 'responded',
        lastMessageAt: serverTimestamp(),
        lastMessageText: reply.trim()
      });

      setReply("");
    } catch (error) {
      alert("Error sending response");
    } finally {
      setSendingReply(false);
    }
  };

  const deleteTicket = async (id: string) => {
    if (!confirm("Are you sure you want to permanently purge this signal? This action cannot be undone.")) return;
    try {
      await deleteDoc(doc(db, "support_tickets", id));
      setSelectedTicket(null);
    } catch (error) {
      alert("Error purging ticket");
    }
  };

  return (
    <div className="p-10 pb-20 space-y-10 animate-in fade-in duration-700">
      <header className="flex flex-col md:flex-row md:items-end justify-between gap-6 mb-4">
        <div>
          <div className="flex items-center gap-3 mb-2">
            <div className="w-1.5 h-6 bg-[#D4AF37] rounded-full" />
            <p className="text-[10px] font-black text-stone-400 uppercase tracking-[0.4em]">Customer Relations</p>
          </div>
          <h1 className="text-6xl font-black text-white uppercase italic tracking-tighter leading-none">Support Station</h1>
        </div>
        <div className="text-left md:text-right">
          <p className="text-[10px] font-black text-stone-400 uppercase tracking-widest mb-1">Response Queue</p>
          <p className="text-xs font-bold text-amber-500 uppercase flex items-center gap-2 md:justify-end">
            <span className="w-2 h-2 rounded-full bg-amber-500 animate-pulse" /> {tickets.filter(t => t.status !== 'resolved').length} Pending Requests
          </p>
        </div>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-10 h-[calc(100vh-280px)]">
        {/* Ticket List */}
        <div className="lg:col-span-1 space-y-4 overflow-y-auto pr-2 custom-scrollbar">
          <h3 className="text-[10px] font-black text-stone-400 uppercase tracking-[0.5em] px-4 mb-6 opacity-60">Recent Transmissions</h3>
          {tickets.map((t) => (
            <div 
              key={t.id} 
              onClick={() => setSelectedTicket(t)}
              className={`bg-[#161616] border p-6 cursor-pointer transition-all relative overflow-hidden group rounded-[2rem] ${
                selectedTicket?.id === t.id ? 'border-[#D4AF37]/50 bg-white/[0.05] scale-[1.02]' : 'border-[#2A2A2A]'
              } ${t.status === 'resolved' ? 'opacity-40 grayscale' : ''}`}
            >
              <div className="flex justify-between items-start mb-4 relative z-10">
                <span className="text-[9px] font-black text-[#D4AF37] uppercase tracking-widest">Signal #{t.id.slice(0,6)}</span>
                {t.status === 'resolved' ? (
                  <div className="px-3 py-1 bg-emerald-500/10 rounded-full border border-emerald-500/20">
                    <p className="text-[8px] font-black text-emerald-500 uppercase">Resolved</p>
                  </div>
                ) : (
                  <div className="px-3 py-1 bg-amber-500/10 rounded-full border border-amber-500/20 animate-pulse">
                    <p className="text-[8px] font-black text-amber-500 uppercase">Awaiting</p>
                  </div>
                )}
              </div>
              <p className="font-black text-white text-lg tracking-tight leading-tight group-hover:text-[#D4AF37] transition-colors mb-2 relative z-10">{t.subject || 'No Subject'}</p>
              <div className="flex items-center justify-between mt-2 relative z-10">
                <div className="flex items-center gap-2">
                  <div className="w-5 h-5 rounded-lg bg-stone-900 flex items-center justify-center border border-[#2A2A2A]">
                    <User size={10} className="text-stone-400" />
                  </div>
                  <p className="text-[9px] text-stone-400 uppercase font-black tracking-widest truncate max-w-[120px]">{t.userEmail}</p>
                </div>
                {t.deletedByUser && (
                  <div className="flex items-center gap-1 px-2 py-0.5 bg-rose-500/10 border border-rose-500/20 rounded-md">
                    <span className="w-1 h-1 rounded-full bg-rose-500 animate-pulse" />
                    <span className="text-[7px] font-black text-rose-500 uppercase">User Cleared</span>
                  </div>
                )}
              </div>
            </div>
          ))}
          {tickets.length === 0 && !fetching && (
            <div className="p-12 text-center bg-[#161616] border-2 border-dashed border-[#2A2A2A] rounded-[2rem]">
              <p className="text-[10px] font-black text-stone-500 uppercase tracking-widest">Communications Clear</p>
            </div>
          )}
        </div>

        {/* Ticket Content (Chat) */}
        <div className="lg:col-span-2">
          {selectedTicket ? (
            <div className="bg-[#161616] border border-[#2A2A2A] h-full flex flex-col overflow-hidden rounded-[2.5rem]">
              <div className="p-8 border-b border-[#2A2A2A] bg-white/[0.01] flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                <div className="flex items-center gap-5">
                  <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-[#D4AF37] to-amber-700 flex items-center justify-center text-[#0A0A0A] shadow-2xl">
                    <User size={24} />
                  </div>
                  <div>
                    <h3 className="text-xl font-black text-white tracking-tight leading-none mb-1.5">{selectedTicket.userName || 'Customer'}</h3>
                    <p className="text-[10px] text-[#D4AF37] uppercase font-black tracking-[0.2em]">{selectedTicket.userEmail}</p>
                  </div>
                </div>
                <div className="flex items-center gap-4">
                  <button 
                    onClick={() => deleteTicket(selectedTicket.id)}
                    className="p-3 px-6 bg-rose-600/10 hover:bg-rose-600 border border-rose-600/30 text-rose-500 hover:text-white rounded-xl font-black text-[10px] uppercase tracking-widest transition-all active:scale-95"
                  >
                    <Trash2 size={14} className="inline mr-2" />
                    Purge Signal
                  </button>
                  {selectedTicket.status !== 'resolved' && (
                    <button 
                      onClick={() => resolveTicket(selectedTicket.id)}
                      className="p-3 px-6 bg-[#D4AF37] hover:bg-white text-[#0A0A0A] rounded-xl font-black text-[10px] uppercase tracking-widest transition-all active:scale-95"
                    >
                      Close Ticket
                    </button>
                  )}
                </div>
              </div>

              {/* Chat Thread */}
              <div className="flex-1 p-8 overflow-y-auto space-y-6 flex flex-col custom-scrollbar">
                {/* Initial Message */}
                <div className="self-start max-w-[80%] space-y-2">
                  <p className="text-[9px] font-black text-stone-400 uppercase tracking-widest px-4">Original Inquiry</p>
                  <div className="p-6 bg-stone-900 border border-[#2A2A2A] rounded-[2rem] rounded-tl-none text-stone-300 font-medium">
                    <p className="text-[#D4AF37] text-xs font-black uppercase tracking-widest mb-2 underline decoration-[#D4AF37]/30 decoration-2 underline-offset-4">{selectedTicket.subject}</p>
                    {selectedTicket.message}
                  </div>
                </div>

                {/* Subcollection Messages */}
                {messages.map((msg) => (
                  <div 
                    key={msg.id} 
                    className={`${msg.sender === 'admin' ? 'self-end' : 'self-start'} max-w-[80%] space-y-2`}
                  >
                    <p className={`text-[9px] font-black text-stone-400 uppercase tracking-widest px-4 ${msg.sender === 'admin' ? 'text-right' : ''}`}>
                      {msg.sender === 'admin' ? 'Official Response' : 'User Reply'}
                    </p>
                    <div className={`p-6 border rounded-[2rem] ${
                      msg.sender === 'admin' 
                        ? 'bg-[#D4AF37]/10 border-[#D4AF37]/30 text-white rounded-tr-none' 
                        : 'bg-stone-900 border-[#2A2A2A] text-stone-300 font-medium rounded-tl-none'
                    }`}>
                      {msg.text}
                      {msg.timestamp && (
                        <p className={`text-[8px] mt-2 opacity-40 font-black ${msg.sender === 'admin' ? 'text-right' : ''}`}>
                          {msg.timestamp.toDate().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                        </p>
                      )}
                    </div>
                  </div>
                ))}
              </div>

              {/* Reply Input */}
              <div className="p-8 pb-10 bg-white/[0.01] border-t border-[#2A2A2A] mt-auto">
                <div className="relative group">
                  <input 
                    value={reply}
                    onChange={(e) => setReply(e.target.value)}
                    className="terminal-input w-full pr-16"
                    placeholder="Securely respond to client identity..."
                    onKeyDown={(e) => e.key === 'Enter' && sendResponse()}
                  />
                  <button 
                    onClick={sendResponse}
                    disabled={sendingReply}
                    className="absolute right-4 top-1/2 -translate-y-1/2 p-3 bg-[#D4AF37] hover:bg-white text-[#0A0A0A] rounded-xl transition-all shadow-xl active:scale-95 disabled:opacity-50"
                  >
                    {sendingReply ? <Loader2 className="animate-spin" size={18} /> : <Send size={18} />}
                  </button>
                </div>
              </div>
            </div>
          ) : (
            <div className="bg-[#161616] border-2 border-dashed border-[#2A2A2A] h-full flex items-center justify-center rounded-[2.5rem] opacity-30">
              <div className="text-center">
                <div className="w-20 h-20 bg-stone-900 rounded-full flex items-center justify-center mx-auto mb-6">
                  <MessageSquare size={40} className="text-stone-400" />
                </div>
                <p className="text-[10px] font-black text-stone-400 uppercase tracking-[0.4em]">Awaiting Signal Acquisition</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

