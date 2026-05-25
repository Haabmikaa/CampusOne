"use client";

import React, { useEffect, useState } from "react";
import {
  collection,
  query,
  orderBy,
  onSnapshot,
  doc,
  deleteDoc,
  addDoc,
  getDocs,
  serverTimestamp,
  Timestamp,
  where,
  writeBatch,
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import {
  Megaphone,
  Send,
  Image as ImageIcon,
  Trash2,
  Loader2,
  AlertTriangle,
  CheckCircle2,
  Eye,
  MousePointerClick,
  BarChart2,
  Clock,
} from "lucide-react";

interface Broadcast {
  id: string;
  title: string;
  body: string;
  imageUrl?: string;
  audience: "all" | "student" | "staff";
  createdAt: Timestamp | Date | null;
  viewCount: number;
  clickCount: number;
}

export default function BroadcastsPage() {
  const [tab, setTab] = useState<"compose" | "history">("compose");
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [imageUrl, setImageUrl] = useState("");
  const [audience, setAudience] = useState<"all" | "student" | "staff">("all");
  const [sending, setSending] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState("");
  const [history, setHistory] = useState<Broadcast[]>([]);
  const [loadingHistory, setLoadingHistory] = useState(true);

  useEffect(() => {
    const q = query(
      collection(db, "broadcasts"),
      orderBy("createdAt", "desc")
    );
    const unsub = onSnapshot(q, (snap) => {
      setHistory(
        snap.docs.map((d) => ({
          id: d.id,
          viewCount: 0,
          clickCount: 0,
          ...d.data(),
        })) as Broadcast[]
      );
      setLoadingHistory(false);
    });
    return () => unsub();
  }, []);

  const handleBroadcast = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title || !body) return;

    setSending(true);
    setError("");
    setSuccess(false);

    try {
      const trimmedImageUrl = imageUrl.trim();
      const broadcastPayload: Record<string, unknown> = {
        title,
        body,
        audience,
        type: "broadcast",
        createdAt: serverTimestamp(),
        viewCount: 0,
        clickCount: 0,
      };

      if (trimmedImageUrl) {
        broadcastPayload.imageUrl = trimmedImageUrl;
      }

      const broadcastRef = await addDoc(collection(db, "broadcasts"), broadcastPayload);

      let recipientsQuery;
      if (audience === "student") {
        recipientsQuery = query(collection(db, "users"), where("role", "==", "student"));
      } else if (audience === "staff") {
        recipientsQuery = query(collection(db, "users"), where("role", "in", ["staff", "lecturer"]));
      } else {
        recipientsQuery = query(collection(db, "users"));
      }

      const recipientsSnap = await getDocs(recipientsQuery);
      if (!recipientsSnap.empty) {
        const batch = writeBatch(db);
        recipientsSnap.docs.forEach((userDoc) => {
          const notificationRef = doc(collection(db, "users", userDoc.id, "notifications"));
          const notificationPayload: Record<string, unknown> = {
            title,
            body,
            audience,
            type: "broadcast",
            isRead: false,
            referenceId: broadcastRef.id,
            createdAt: serverTimestamp(),
          };

          if (trimmedImageUrl) {
            notificationPayload.imageUrl = trimmedImageUrl;
          }

          batch.set(notificationRef, notificationPayload);
        });
        await batch.commit();
      }

      // Send FCM push notification
      const response = await fetch("/api/broadcast", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ title, body, imageUrl: trimmedImageUrl || null, topic: audience }),
      });

      const data = await response.json();
      if (!response.ok) throw new Error(data.error || "Push notification failed");

      setSuccess(true);
      setTitle("");
      setBody("");
      setImageUrl("");
      setAudience("all");
      setTimeout(() => setSuccess(false), 5000);
    } catch (err: unknown) {
      setError(err instanceof Error ? err.message : "An error occurred.");
    } finally {
      setSending(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Delete this broadcast permanently?")) return;
    await deleteDoc(doc(db, "broadcasts", id));
  };

  const formatDate = (ts: Timestamp | Date | null) => {
    if (!ts) return "—";
    const date = ts instanceof Timestamp ? ts.toDate() : new Date(ts);
    return date.toLocaleString("en-US", { month: "short", day: "numeric", hour: "2-digit", minute: "2-digit" });
  };

  const totalViews = history.reduce((s, b) => s + (b.viewCount || 0), 0);
  const totalClicks = history.reduce((s, b) => s + (b.clickCount || 0), 0);
  const avgCTR = totalViews > 0 ? ((totalClicks / totalViews) * 100).toFixed(1) : "0.0";

  return (
    <div className="p-10 pb-20 space-y-10 animate-in fade-in duration-700">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-6">
        <div>
          <p className="text-[10px] font-black text-stone-400 uppercase tracking-[0.4em] mb-2">
            Global Communications
          </p>
          <h1 className="text-5xl font-black text-white uppercase italic tracking-tighter leading-none flex items-center gap-4">
            <Megaphone size={40} className="text-[#D4AF37]" />
            Broadcasts
          </h1>
        </div>

        {/* Tab switcher */}
        <div className="flex bg-[#161616] border border-[#2A2A2A] rounded-2xl p-1.5 gap-1">
          {(["compose", "history"] as const).map((t) => (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={`px-6 py-2.5 rounded-xl text-[11px] font-black uppercase tracking-widest transition-all duration-300 ${
                tab === t
                  ? "bg-[#D4AF37] text-[#0A0A0A] shadow-lg"
                  : "text-stone-400 hover:text-white"
              }`}
            >
              {t === "compose" ? "Compose" : `History (${history.length})`}
            </button>
          ))}
        </div>
      </div>

      {tab === "compose" ? (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-10">
          {/* Form */}
          <div className="lg:col-span-2 bg-[#161616] border border-[#2A2A2A] rounded-[2.5rem] p-10 backdrop-blur-xl">
            <form onSubmit={handleBroadcast} className="space-y-8">
              <div className="space-y-3">
                <label className="text-[10px] font-black text-stone-400 uppercase tracking-widest">
                  Broadcast Title
                </label>
                <input
                  required
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  maxLength={50}
                  className="terminal-input w-full text-lg font-bold"
                  placeholder="e.g., MEGA SALE: 50% OFF TODAY ONLY!"
                />
                <div className="flex justify-end">
                  <span className="text-[9px] text-stone-400 font-bold">{title.length}/50</span>
                </div>
              </div>

              <div className="space-y-3">
                <label className="text-[10px] font-black text-stone-400 uppercase tracking-widest">
                  Message Body
                </label>
                <textarea
                  required
                  rows={4}
                  value={body}
                  onChange={(e) => setBody(e.target.value)}
                  maxLength={150}
                  className="terminal-input w-full resize-none leading-relaxed"
                  placeholder="Describe your announcement..."
                />
                <div className="flex justify-end">
                  <span className="text-[9px] text-stone-400 font-bold">{body.length}/150</span>
                </div>
              </div>

              <div className="space-y-3">
                <label className="text-[10px] font-black text-[#D4AF37] uppercase tracking-widest flex items-center gap-2">
                  <ImageIcon size={12} /> Image URL (Optional)
                </label>
                <input
                  value={imageUrl}
                  onChange={(e) => setImageUrl(e.target.value)}
                  className="terminal-input w-full"
                  placeholder="https://example.com/banner.jpg"
                />
              </div>

              {/* Audience Selector */}
              <div className="space-y-3">
                <label className="text-[10px] font-black text-stone-400 uppercase tracking-widest">Send To (Audience)</label>
                <div className="flex gap-3">
                  {(["all", "student", "staff"] as const).map((a) => (
                    <button
                      key={a}
                      type="button"
                      onClick={() => setAudience(a)}
                      className={`flex-1 py-3 rounded-xl text-[10px] font-black uppercase tracking-widest transition-all border ${
                        audience === a
                          ? a === 'staff'
                            ? 'bg-emerald-500 text-white border-emerald-500 shadow-lg shadow-emerald-500/20'
                            : a === 'student'
                            ? 'bg-blue-500 text-white border-blue-500 shadow-lg shadow-blue-500/20'
                            : 'bg-[#D4AF37] text-black border-[#D4AF37] shadow-lg shadow-yellow-500/20'
                          : 'bg-black border-[#2A2A2A] text-stone-500 hover:text-white'
                      }`}
                    >
                      {a === 'all' ? '🌐 Everyone' : a === 'student' ? '🎓 Students Only' : '🛠️ Staff Only'}
                    </button>
                  ))}
                </div>
              </div>

              {error && (
                <div className="p-4 bg-rose-500/10 border border-rose-500/20 rounded-2xl flex items-center gap-3">
                  <AlertTriangle size={16} className="text-rose-500" />
                  <p className="text-xs font-bold text-rose-400">{error}</p>
                </div>
              )}
              {success && (
                <div className="p-4 bg-emerald-500/10 border border-emerald-500/20 rounded-2xl flex items-center gap-3">
                  <CheckCircle2 size={16} className="text-emerald-500" />
                  <p className="text-xs font-bold text-emerald-400 uppercase tracking-widest">
                    Broadcast sent successfully!
                  </p>
                </div>
              )}

              <button
                type="submit"
                disabled={sending || !title || !body}
                className="w-full h-20 bg-[#D4AF37] hover:bg-white text-[#0A0A0A] font-black rounded-[2rem] flex items-center justify-center gap-4 transition-all duration-500 shadow-2xl active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {sending ? (
                  <Loader2 className="animate-spin" size={24} />
                ) : (
                  <>
                    <Send size={20} />
                    <span className="text-lg uppercase italic tracking-tighter">
                      Execute Global Broadcast
                    </span>
                  </>
                )}
              </button>
            </form>
          </div>

          {/* Live preview */}
          <div className="space-y-6">
            <p className="text-[10px] font-black text-stone-400 uppercase tracking-widest px-2">
              Live Preview
            </p>
            <div
              className={`bg-stone-900 border border-[#2A2A2A] p-5 rounded-3xl transition-all duration-500 ${
                title ? "opacity-100 translate-y-0" : "opacity-40"
              }`}
            >
              <div className="flex items-center gap-2 mb-3">
                <div className="w-5 h-5 bg-[#D4AF37] rounded-md flex items-center justify-center">
                  <span className="text-[8px] font-black text-[#0A0A0A]">E</span>
                </div>
                <span className="text-[10px] font-bold text-stone-300 uppercase tracking-widest">
                  EthioShop
                </span>
                <span className="text-[10px] text-stone-400 ml-auto">now</span>
              </div>
              <h4 className="text-sm font-black text-white leading-tight mb-1">
                {title || "Notification Title"}
              </h4>
              <p className="text-xs text-stone-300 line-clamp-2">
                {body || "Notification body text will appear here."}
              </p>
              {imageUrl && (
                <div className="mt-3 w-full h-28 rounded-xl overflow-hidden">
                  <img
                    src={imageUrl}
                    alt="Preview"
                    className="w-full h-full object-cover"
                    onError={(e) => (e.currentTarget.style.display = "none")}
                  />
                </div>
              )}
            </div>
          </div>
        </div>
      ) : (
        /* History Tab */
        <div className="space-y-8">
          {/* Analytics Cards */}
          <div className="grid grid-cols-3 gap-6">
            {[
              { label: "Total Sent", value: history.length, icon: Megaphone, color: "text-[#D4AF37]" },
              { label: "Total Views", value: totalViews.toLocaleString(), icon: Eye, color: "text-amber-400" },
              { label: "Avg CTR", value: `${avgCTR}%`, icon: MousePointerClick, color: "text-emerald-400" },
            ].map((stat) => (
              <div
                key={stat.label}
                className="bg-[#161616] border border-[#2A2A2A] rounded-[2rem] p-8 backdrop-blur-xl"
              >
                <stat.icon size={24} className={`${stat.color} mb-4`} />
                <p className="text-3xl font-black text-white">{stat.value}</p>
                <p className="text-[10px] font-black text-stone-400 uppercase tracking-widest mt-1">
                  {stat.label}
                </p>
              </div>
            ))}
          </div>

          {/* Broadcast List */}
          {loadingHistory ? (
            <div className="h-40 flex items-center justify-center">
              <Loader2 className="animate-spin text-stone-500" size={32} />
            </div>
          ) : history.length === 0 ? (
            <div className="text-center py-24 text-stone-500">
              <BarChart2 size={48} className="mx-auto mb-4 opacity-30" />
              <p className="font-black uppercase tracking-widest text-sm">No broadcasts yet</p>
            </div>
          ) : (
            <div className="space-y-4">
              {history.map((b) => (
                <div
                  key={b.id}
                  className="bg-[#161616] border border-[#2A2A2A] rounded-[2rem] p-6 backdrop-blur-xl flex items-center gap-6 group hover:border-[#D4AF37]/10 transition-all"
                >
                  {b.imageUrl ? (
                    <div className="w-16 h-16 rounded-2xl overflow-hidden shrink-0 bg-stone-950">
                      <img
                        src={b.imageUrl}
                        alt=""
                        className="w-full h-full object-cover"
                        onError={(e) => (e.currentTarget.style.display = "none")}
                      />
                    </div>
                  ) : (
                    <div className="w-16 h-16 rounded-2xl bg-[#D4AF37]/10 border border-[#D4AF37]/20 flex items-center justify-center shrink-0">
                      <Megaphone size={24} className="text-[#D4AF37]" />
                    </div>
                  )}

                  <div className="flex-1 min-w-0">
                    <p className="font-black text-white text-sm uppercase tracking-wide truncate">
                      {b.title}
                    </p>
                    <p className="text-xs text-stone-400 truncate mt-1">{b.body}</p>
                    <div className="flex items-center gap-1 mt-2 text-stone-400">
                      <Clock size={10} />
                      <span className="text-[10px] font-bold">{formatDate(b.createdAt)}</span>
                    </div>
                  </div>

                  {/* Analytics */}
                  <div className="flex items-center gap-6 shrink-0">
                    <div className="text-center">
                      <div className="flex items-center gap-1.5 text-amber-500">
                        <Eye size={14} />
                        <span className="text-lg font-black text-white">{b.viewCount || 0}</span>
                      </div>
                      <p className="text-[9px] font-black text-stone-400 uppercase tracking-widest">Views</p>
                    </div>
                    <div className="text-center">
                      <div className="flex items-center gap-1.5 text-emerald-400">
                        <MousePointerClick size={14} />
                        <span className="text-lg font-black text-white">{b.clickCount || 0}</span>
                      </div>
                      <p className="text-[9px] font-black text-stone-400 uppercase tracking-widest">Clicks</p>
                    </div>
                    <div className="text-center">
                      <span className="text-lg font-black text-white">
                        {b.viewCount > 0 ? ((b.clickCount / b.viewCount) * 100).toFixed(0) : 0}%
                      </span>
                      <p className="text-[9px] font-black text-stone-400 uppercase tracking-widest">CTR</p>
                    </div>
                  </div>

                  <button
                    onClick={() => handleDelete(b.id)}
                    className="p-3 rounded-xl hover:bg-rose-500/10 hover:text-rose-500 text-stone-400 transition-all"
                  >
                    <Trash2 size={16} />
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

