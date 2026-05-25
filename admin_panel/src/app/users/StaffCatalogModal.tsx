"use client";

import React, { useState, useEffect } from "react";
import { collection, onSnapshot, addDoc, deleteDoc, doc, query, orderBy } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { X, Plus, Trash2, Building, Loader2 } from "lucide-react";

export default function StaffCatalogModal({ onClose }: { onClose: () => void }) {
  const [catalogs, setCatalogs] = useState<{ id: string; name: string }[]>([]);
  const [newName, setNewName] = useState("");
  const [loading, setLoading] = useState(true);
  const [isAdding, setIsAdding] = useState(false);

  useEffect(() => {
    const q = query(collection(db, "staffCatalogs"), orderBy("name", "asc"));
    const unsub = onSnapshot(q, (snap) => {
      setCatalogs(snap.docs.map(d => ({ id: d.id, name: d.data().name })));
      setLoading(false);
    });
    return () => unsub();
  }, []);

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newName.trim()) return;
    setIsAdding(true);
    try {
      await addDoc(collection(db, "staffCatalogs"), { name: newName.trim() });
      setNewName("");
    } catch (e) {
      console.error(e);
      alert("Failed to add catalog");
    } finally {
      setIsAdding(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Delete this catalog? Users in this catalog will NOT be deleted.")) return;
    try {
      await deleteDoc(doc(db, "staffCatalogs", id));
    } catch (e) {
      console.error(e);
    }
  };

  return (
    <div className="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/80 backdrop-blur-md animate-in fade-in">
      <div className="bg-[#161616] border border-[#2A2A2A] rounded-[2.5rem] w-full max-w-md overflow-hidden shadow-2xl relative">
        <div className="p-8 border-b border-[#2A2A2A] flex items-center justify-between">
          <div>
            <h2 className="text-xl font-black text-white uppercase tracking-widest flex items-center gap-3">
              <Building size={20} className="text-[#D4AF37]" />
              Staff Catalogs
            </h2>
            <p className="text-[10px] font-bold text-stone-500 uppercase tracking-widest mt-1">Manage categories like maintenance, cafeteria</p>
          </div>
          <button onClick={onClose} className="text-stone-500 hover:text-white transition-colors p-2 hover:bg-white/5 rounded-full">
            <X size={20} />
          </button>
        </div>

        <div className="p-8 space-y-6">
          <form onSubmit={handleAdd} className="flex gap-2">
            <input
              type="text"
              value={newName}
              onChange={(e) => setNewName(e.target.value)}
              placeholder="New catalog (e.g. Maintenance)"
              className="flex-1 bg-black border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-all"
            />
            <button
              type="submit"
              disabled={isAdding || !newName.trim()}
              className="bg-[#D4AF37] text-[#0A0A0A] p-3 rounded-xl hover:bg-[#b08d2c] transition-colors disabled:opacity-50"
            >
              {isAdding ? <Loader2 size={18} className="animate-spin" /> : <Plus size={18} />}
            </button>
          </form>

          <div className="space-y-2 max-h-[300px] overflow-y-auto custom-scrollbar pr-2">
            {loading ? (
              <div className="py-10 text-center">
                <Loader2 size={20} className="animate-spin text-stone-600 mx-auto" />
              </div>
            ) : catalogs.length === 0 ? (
              <p className="text-center py-10 text-stone-500 text-xs font-bold uppercase tracking-widest">No catalogs added yet</p>
            ) : (
              catalogs.map((cat) => (
                <div key={cat.id} className="flex items-center justify-between p-4 bg-black/40 border border-[#2A2A2A] rounded-2xl group hover:border-[#D4AF37]/30 transition-all">
                  <span className="text-sm font-bold text-white group-hover:text-[#D4AF37] transition-colors">{cat.name}</span>
                  <button
                    onClick={() => handleDelete(cat.id)}
                    className="text-stone-600 hover:text-rose-500 transition-colors p-1"
                  >
                    <Trash2 size={14} />
                  </button>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
