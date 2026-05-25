"use client";

import React, { useEffect, useState } from "react";
import {
  collection,
  query,
  orderBy,
  onSnapshot,
  addDoc,
  deleteDoc,
  doc,
  serverTimestamp,
  Timestamp,
} from "firebase/firestore";
import { db } from "@/lib/firebase";
import {
  Calendar,
  Image as ImageIcon,
  MapPin,
  Clock,
  Trash2,
  Loader2,
  CheckCircle2,
  AlertTriangle,
  Sparkles,
  Users,
  Tag,
  Plus,
  ArrowRight,
  Pin,
} from "lucide-react";

interface EventPost {
  id: string;
  title: string;
  body: string;
  category: string;
  imageUrl?: string;
  location?: string;
  eventDate?: string;
  eventTime?: string;
  audience: "all" | "student" | "staff";
  isUrgent: boolean;
  isPinned: boolean;
  createdAt: any;
}

const CATEGORIES = ["Academic", "Events", "Staff", "Sports", "IT", "Library", "General"];
const AUDIENCES = [
  { value: "all", label: "🌐 Everyone", color: "yellow" },
  { value: "student", label: "🎓 Students", color: "blue" },
  { value: "staff", label: "🛠️ Staff Only", color: "emerald" },
] as const;

const CAT_COLORS: Record<string, string> = {
  Academic: "#3B82F6", Events: "#8B5CF6", Staff: "#10B981",
  Sports: "#F59E0B", IT: "#0EA5E9", Library: "#F97316", General: "#6366F1",
};

export default function EventsPage() {
  const [tab, setTab] = useState<"compose" | "feed">("compose");

  // Form state
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");
  const [category, setCategory] = useState("Academic");
  const [imageUrl, setImageUrl] = useState("");
  const [location, setLocation] = useState("");
  const [eventDate, setEventDate] = useState("");
  const [eventTime, setEventTime] = useState("");
  const [audience, setAudience] = useState<"all" | "student" | "staff">("all");
  const [isUrgent, setIsUrgent] = useState(false);
  const [isPinned, setIsPinned] = useState(false);

  const [sending, setSending] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState("");

  const [events, setEvents] = useState<EventPost[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const q = query(collection(db, "announcements"), orderBy("createdAt", "desc"));
    return onSnapshot(q, (snap) => {
      setEvents(snap.docs.map((d) => ({ id: d.id, ...d.data() } as EventPost)));
      setLoading(false);
    });
  }, []);

  const handlePost = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title || !body) return;
    setSending(true);
    setError("");
    try {
      await addDoc(collection(db, "announcements"), {
        title,
        body,
        category,
        imageUrl: imageUrl || null,
        location: location || null,
        eventDate: eventDate || null,
        eventTime: eventTime || null,
        audience,
        isUrgent,
        isPinned,
        createdAt: serverTimestamp(),
      });
      setSuccess(true);
      setTitle(""); setBody(""); setImageUrl(""); setLocation("");
      setEventDate(""); setEventTime(""); setIsUrgent(false); setIsPinned(false);
      setTimeout(() => setSuccess(false), 4000);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setSending(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Delete this post?")) return;
    await deleteDoc(doc(db, "announcements", id));
  };

  const formatDate = (ts: any) => {
    if (!ts) return "—";
    const d = ts instanceof Timestamp ? ts.toDate() : new Date(ts);
    return d.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" });
  };

  return (
    <div className="p-8 pb-20 space-y-8 animate-in fade-in duration-500">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-6">
        <div>
          <p className="text-[10px] font-black text-stone-500 uppercase tracking-[0.4em] mb-2">Campus Comms</p>
          <h1 className="text-5xl font-black text-white uppercase italic tracking-tighter leading-none flex items-center gap-4">
            <div className="p-3 bg-violet-500/10 rounded-2xl border border-violet-500/20">
              <Calendar size={36} className="text-violet-400" />
            </div>
            Events & Notices
          </h1>
        </div>
        <div className="flex bg-[#161616] border border-[#2A2A2A] rounded-2xl p-1.5 gap-1">
          {(["compose", "feed"] as const).map((t) => (
            <button key={t} onClick={() => setTab(t)}
              className={`px-6 py-2.5 rounded-xl text-[11px] font-black uppercase tracking-widest transition-all ${
                tab === t ? "bg-violet-500 text-white shadow-lg shadow-violet-500/30" : "text-stone-400 hover:text-white"
              }`}>
              {t === "compose" ? "Compose" : `Feed (${events.length})`}
            </button>
          ))}
        </div>
      </div>

      {tab === "compose" ? (
        <div className="grid grid-cols-1 xl:grid-cols-3 gap-8">
          {/* ── Form ── */}
          <div className="xl:col-span-2 space-y-6">
            <form onSubmit={handlePost} className="bg-[#111118] border border-[#2A2A2A] rounded-[2.5rem] p-8 space-y-7">
              
              {/* Title */}
              <div className="space-y-2">
                <label className="text-[10px] font-black text-stone-500 uppercase tracking-widest">Title *</label>
                <input required value={title} onChange={(e) => setTitle(e.target.value)} maxLength={80}
                  className="w-full bg-[#0A0A12] border border-[#2A2A2A] rounded-2xl px-5 py-4 text-lg font-bold text-white placeholder-stone-700 focus:outline-none focus:border-violet-500 transition-colors"
                  placeholder="e.g. Final Exam Week Announcement" />
                <div className="text-right text-[9px] text-stone-600 font-bold">{title.length}/80</div>
              </div>

              {/* Body */}
              <div className="space-y-2">
                <label className="text-[10px] font-black text-stone-500 uppercase tracking-widest">Message Body *</label>
                <textarea required rows={5} value={body} onChange={(e) => setBody(e.target.value)} maxLength={500}
                  className="w-full bg-[#0A0A12] border border-[#2A2A2A] rounded-2xl px-5 py-4 text-sm text-white placeholder-stone-700 focus:outline-none focus:border-violet-500 transition-colors resize-none leading-relaxed"
                  placeholder="Write your detailed announcement here..." />
                <div className="text-right text-[9px] text-stone-600 font-bold">{body.length}/500</div>
              </div>

              {/* Category + Audience */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-[10px] font-black text-stone-500 uppercase tracking-widest flex items-center gap-2"><Tag size={10} />Category</label>
                  <div className="flex flex-wrap gap-2">
                    {CATEGORIES.map((c) => (
                      <button key={c} type="button" onClick={() => setCategory(c)}
                        className={`px-3 py-1.5 rounded-xl text-[10px] font-black uppercase tracking-wider transition-all border ${
                          category === c ? "text-white border-transparent" : "bg-[#0A0A12] border-[#2A2A2A] text-stone-500 hover:text-white"
                        }`}
                        style={category === c ? { backgroundColor: CAT_COLORS[c], borderColor: CAT_COLORS[c] } : {}}>
                        {c}
                      </button>
                    ))}
                  </div>
                </div>

                <div className="space-y-2">
                  <label className="text-[10px] font-black text-stone-500 uppercase tracking-widest flex items-center gap-2"><Users size={10} />Send To</label>
                  <div className="flex flex-col gap-2">
                    {AUDIENCES.map((a) => (
                      <button key={a.value} type="button" onClick={() => setAudience(a.value)}
                        className={`w-full py-2.5 rounded-xl text-[10px] font-black uppercase tracking-wider transition-all border text-left px-4 ${
                          audience === a.value
                            ? a.color === "yellow" ? "bg-amber-500/20 border-amber-500 text-amber-400"
                              : a.color === "blue" ? "bg-blue-500/20 border-blue-500 text-blue-400"
                              : "bg-emerald-500/20 border-emerald-500 text-emerald-400"
                            : "bg-[#0A0A12] border-[#2A2A2A] text-stone-500 hover:text-white"
                        }`}>
                        {a.label}
                      </button>
                    ))}
                  </div>
                </div>
              </div>

              {/* Banner Image URL */}
              <div className="space-y-2">
                <label className="text-[10px] font-black text-stone-500 uppercase tracking-widest flex items-center gap-2"><ImageIcon size={10} />Banner Image URL (Optional)</label>
                <input value={imageUrl} onChange={(e) => setImageUrl(e.target.value)}
                  className="w-full bg-[#0A0A12] border border-[#2A2A2A] rounded-2xl px-5 py-3 text-sm text-white placeholder-stone-700 focus:outline-none focus:border-violet-500 transition-colors"
                  placeholder="https://your-image-url.com/banner.jpg" />
                {imageUrl && (
                  <div className="mt-2 rounded-2xl overflow-hidden h-36 bg-stone-900">
                    <img src={imageUrl} alt="Preview" className="w-full h-full object-cover"
                      onError={(e) => (e.currentTarget.style.display = "none")} />
                  </div>
                )}
              </div>

              {/* Event-specific fields */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="space-y-2">
                  <label className="text-[10px] font-black text-stone-500 uppercase tracking-widest flex items-center gap-2"><MapPin size={10} />Venue (Optional)</label>
                  <input value={location} onChange={(e) => setLocation(e.target.value)}
                    className="w-full bg-[#0A0A12] border border-[#2A2A2A] rounded-2xl px-4 py-3 text-sm text-white placeholder-stone-700 focus:outline-none focus:border-violet-500 transition-colors"
                    placeholder="Main Hall / Online" />
                </div>
                <div className="space-y-2">
                  <label className="text-[10px] font-black text-stone-500 uppercase tracking-widest flex items-center gap-2"><Calendar size={10} />Event Date</label>
                  <input type="date" value={eventDate} onChange={(e) => setEventDate(e.target.value)}
                    className="w-full bg-[#0A0A12] border border-[#2A2A2A] rounded-2xl px-4 py-3 text-sm text-white focus:outline-none focus:border-violet-500 transition-colors" />
                </div>
                <div className="space-y-2">
                  <label className="text-[10px] font-black text-stone-500 uppercase tracking-widest flex items-center gap-2"><Clock size={10} />Event Time</label>
                  <input type="time" value={eventTime} onChange={(e) => setEventTime(e.target.value)}
                    className="w-full bg-[#0A0A12] border border-[#2A2A2A] rounded-2xl px-4 py-3 text-sm text-white focus:outline-none focus:border-violet-500 transition-colors" />
                </div>
              </div>

              {/* Flags */}
              <div className="flex gap-4">
                {[
                  { label: "⚡ Mark as Urgent", value: isUrgent, setter: setIsUrgent, activeColor: "border-red-500 bg-red-500/10 text-red-400" },
                  { label: "📌 Pin to Top", value: isPinned, setter: setIsPinned, activeColor: "border-violet-500 bg-violet-500/10 text-violet-400" },
                ].map((flag) => (
                  <button key={flag.label} type="button" onClick={() => flag.setter(!flag.value)}
                    className={`flex-1 py-3 rounded-xl text-[10px] font-black uppercase tracking-widest border transition-all ${
                      flag.value ? flag.activeColor : "border-[#2A2A2A] bg-[#0A0A12] text-stone-600 hover:text-stone-400"
                    }`}>
                    {flag.label}
                  </button>
                ))}
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
                  <p className="text-xs font-bold text-emerald-400 uppercase tracking-widest">Posted to campus feed successfully!</p>
                </div>
              )}

              <button type="submit" disabled={sending || !title || !body}
                className="w-full h-18 py-5 bg-gradient-to-r from-violet-600 to-indigo-600 hover:from-violet-500 hover:to-indigo-500 text-white font-black rounded-[2rem] flex items-center justify-center gap-4 transition-all shadow-2xl shadow-violet-500/20 active:scale-95 disabled:opacity-40 disabled:cursor-not-allowed">
                {sending ? <Loader2 className="animate-spin" size={22} /> : (
                  <>
                    <Sparkles size={20} />
                    <span className="text-lg uppercase italic tracking-tighter">Publish to Campus Feed</span>
                    <ArrowRight size={20} />
                  </>
                )}
              </button>
            </form>
          </div>

          {/* ── Live Preview ── */}
          <div className="space-y-4">
            <p className="text-[10px] font-black text-stone-500 uppercase tracking-widest px-2">Live Preview</p>
            <div className={`rounded-3xl overflow-hidden border transition-all duration-500 ${isPinned ? "border-violet-500/40" : "border-[#2A2A2A]"}`}>
              {/* Banner */}
              {imageUrl ? (
                <div className="h-44 bg-stone-900">
                  <img src={imageUrl} alt="" className="w-full h-full object-cover"
                    onError={(e) => (e.currentTarget.style.display = "none")} />
                </div>
              ) : (
                <div className="h-44 flex items-center justify-center"
                  style={{ background: `linear-gradient(135deg, ${CAT_COLORS[category]}22, ${CAT_COLORS[category]}44)` }}>
                  <Calendar size={48} style={{ color: CAT_COLORS[category], opacity: 0.6 }} />
                </div>
              )}

              <div className="p-5 bg-[#111118] space-y-3">
                <div className="flex items-center gap-2">
                  <span className="text-[9px] font-black uppercase tracking-widest px-2 py-1 rounded-lg"
                    style={{ color: CAT_COLORS[category], backgroundColor: `${CAT_COLORS[category]}22` }}>
                    {category}
                  </span>
                  {isUrgent && <span className="text-[9px] font-black uppercase text-red-400 bg-red-500/10 px-2 py-1 rounded-lg">⚡ Urgent</span>}
                  {isPinned && <Pin size={12} className="text-violet-400 ml-auto" />}
                </div>
                <h3 className="text-white font-bold text-base leading-snug">{title || "Event title appears here"}</h3>
                <p className="text-stone-500 text-xs leading-relaxed line-clamp-3">{body || "Event description..."}</p>
                {(eventDate || location) && (
                  <div className="space-y-1.5">
                    {eventDate && (
                      <div className="flex items-center gap-2 text-stone-400 text-xs">
                        <Calendar size={11} />
                        <span>{eventDate} {eventTime && `· ${eventTime}`}</span>
                      </div>
                    )}
                    {location && (
                      <div className="flex items-center gap-2 text-stone-400 text-xs">
                        <MapPin size={11} />
                        <span>{location}</span>
                      </div>
                    )}
                  </div>
                )}
                <div className="flex items-center justify-between pt-2 border-t border-[#2A2A2A]">
                  <span className="text-[9px] text-stone-600 uppercase tracking-wider">
                    {AUDIENCES.find(a => a.value === audience)?.label}
                  </span>
                  <span className="text-[9px] text-stone-600">Just now</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      ) : (
        /* ── Feed Tab ── */
        <div className="space-y-4">
          {loading ? (
            <div className="h-64 flex items-center justify-center">
              <Loader2 className="animate-spin text-violet-500" size={32} />
            </div>
          ) : events.length === 0 ? (
            <div className="text-center py-24 text-stone-600">
              <Calendar size={48} className="mx-auto mb-4 opacity-30" />
              <p className="font-black uppercase tracking-widest">No events yet</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
              {events.map((ev) => (
                <div key={ev.id}
                  className={`bg-[#111118] border rounded-3xl overflow-hidden group hover:scale-[1.01] transition-all ${ev.isPinned ? "border-violet-500/30" : "border-[#2A2A2A]"}`}>
                  {ev.imageUrl ? (
                    <div className="h-40 overflow-hidden bg-stone-900">
                      <img src={ev.imageUrl} alt="" className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                        onError={(e) => (e.currentTarget.style.display = "none")} />
                    </div>
                  ) : (
                    <div className="h-40 flex items-center justify-center"
                      style={{ background: `linear-gradient(135deg, ${CAT_COLORS[ev.category] ?? "#6366F1"}15, ${CAT_COLORS[ev.category] ?? "#6366F1"}30)` }}>
                      <Calendar size={40} style={{ color: CAT_COLORS[ev.category] ?? "#6366F1", opacity: 0.5 }} />
                    </div>
                  )}

                  <div className="p-5 space-y-3">
                    <div className="flex items-center gap-2 flex-wrap">
                      <span className="text-[9px] font-black uppercase px-2 py-1 rounded-lg"
                        style={{ color: CAT_COLORS[ev.category] ?? "#6366F1", backgroundColor: `${CAT_COLORS[ev.category] ?? "#6366F1"}20` }}>
                        {ev.category}
                      </span>
                      {ev.isUrgent && <span className="text-[9px] font-black text-red-400 bg-red-500/10 px-2 py-1 rounded-lg">⚡ Urgent</span>}
                      {ev.isPinned && <Pin size={10} className="text-violet-400 ml-auto" />}
                    </div>
                    <p className="text-white font-bold text-sm leading-snug line-clamp-2">{ev.title}</p>
                    <p className="text-stone-500 text-xs line-clamp-2 leading-relaxed">{ev.body}</p>
                    {ev.eventDate && (
                      <div className="flex items-center gap-1.5 text-stone-500 text-[10px]">
                        <Calendar size={10} />
                        <span>{ev.eventDate} {ev.eventTime && `· ${ev.eventTime}`}</span>
                      </div>
                    )}
                    <div className="flex items-center justify-between pt-3 border-t border-[#2A2A2A]">
                      <span className="text-[9px] text-stone-600">{formatDate(ev.createdAt)}</span>
                      <div className="flex items-center gap-2">
                        <span className="text-[9px] text-stone-600 capitalize">{ev.audience === "all" ? "Everyone" : ev.audience}</span>
                        <button onClick={() => handleDelete(ev.id)}
                          className="p-1.5 rounded-lg hover:bg-rose-500/10 hover:text-rose-500 text-stone-600 transition-all">
                          <Trash2 size={13} />
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
