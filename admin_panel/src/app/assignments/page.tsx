"use client";

import React, { useState, useEffect } from "react";
import { Sidebar } from "@/components/Sidebar";
import { collection, query, getDocs, addDoc, orderBy, where } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { Layers, Building, BookOpen, Users, CheckCircle, Loader2 } from "lucide-react";

const CANONICAL_DEPARTMENTS = [
  "Architecture",
  "Chemical Engineering",
  "Civil Engineering",
  "Computer Science Engineering",
  "ECE",
  "Electrical Engineering",
  "EPE",
  "Material Engineering",
  "Mathematics",
  "Mechanical Engineering",
  "Physics",
  "Pre Engineering",
  "Software Engineering",
  "Water Resources Engineering",
];

const DEPARTMENT_ALIASES: Record<string, string> = {
  ARCH: "Architecture",
  CE: "Civil Engineering",
  CHE: "Chemical Engineering",
  CHEMICAL_ENGINEERING: "Chemical Engineering",
  CSE: "Computer Science Engineering",
  CS: "Computer Science Engineering",
  ECE: "ECE",
  EEC: "Electrical Engineering",
  EE: "Electrical Engineering",
  ELECTRICAL_ENGINEERING: "Electrical Engineering",
  EPE: "EPE",
  EPCE: "Pre Engineering",
  MATH: "Mathematics",
  MATHEMATICS: "Mathematics",
  ME: "Mechanical Engineering",
  MATERIALS: "Material Engineering",
  MATERIAL_ENGINEERING: "Material Engineering",
  PHYSICS: "Physics",
  PRE: "Pre Engineering",
  PRE_ENGINEERING: "Pre Engineering",
  SE: "Software Engineering",
  SOFTWARE_ENGINEERING: "Software Engineering",
  WRE: "Water Resources Engineering",
  WATER_RESOURCES_ENGINEERING: "Water Resources Engineering",
};

function normalizeDepartmentName(value: string) {
  const trimmed = value.trim();
  if (!trimmed) return "";

  const aliasKey = trimmed
    .toUpperCase()
    .replace(/&/g, "AND")
    .replace(/[^A-Z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");

  return DEPARTMENT_ALIASES[aliasKey] ?? trimmed;
}

export default function AssignmentsPage() {
  const [departments, setDepartments] = useState<string[]>([]);
  const [lecturers, setLecturers] = useState<{id: string, name: string, category: string}[]>([]);
  
  const [selectedDept, setSelectedDept] = useState("");
  const [selectedYear, setSelectedYear] = useState("");
  const [selectedSemester, setSelectedSemester] = useState("");
  const [selectedSection, setSelectedSection] = useState("");
  const [selectedGroup, setSelectedGroup] = useState("Both");
  const [courseCode, setCourseCode] = useState("");
  const [courseTitle, setCourseTitle] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("");
  const [selectedLecturer, setSelectedLecturer] = useState("");
  
  const [loading, setLoading] = useState(false);
  const [fetchingData, setFetchingData] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const deptQ = query(collection(db, "departments"), orderBy("name", "asc"));
        const deptSnap = await getDocs(deptQ);
        const dbDepartments = deptSnap.docs
          .map((d) => normalizeDepartmentName(d.data().name || ""))
          .filter(Boolean);

        setDepartments(
          Array.from(new Set([...CANONICAL_DEPARTMENTS, ...dbDepartments])).sort((a, b) =>
            a.localeCompare(b),
          ),
        );

        const lecQ = query(collection(db, "users"), where("role", "==", "lecturer"));
        const lecSnap = await getDocs(lecQ);
        setLecturers(lecSnap.docs.map(d => ({
          id: d.id,
          name: d.data().name,
          category: d.data().lecturerCategory || "Uncategorized"
        })));
      } catch (err) {
        console.error(err);
      } finally {
        setFetchingData(false);
      }
    };
    fetchData();
  }, []);

  const handleAssign = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedDept || !selectedYear || !selectedSemester || !selectedSection || !courseCode || !courseTitle || !selectedLecturer) {
      alert("Please fill in all fields.");
      return;
    }

    setLoading(true);
    try {
      const normalizedDepartment = normalizeDepartmentName(selectedDept);
      const cohort = `${selectedYear} ${normalizedDepartment}`;
      await addDoc(collection(db, "courses"), {
        courseCode,
        title: courseTitle,
        cohort,
        department: normalizedDepartment,
        year: selectedYear,
        semester: selectedSemester,
        section: selectedSection,
        group: selectedGroup,
        instructorId: selectedLecturer,
        createdAt: new Date()
      });
      alert("Course successfully assigned to lecturer!");
      setCourseCode("");
      setCourseTitle("");
      setSelectedLecturer("");
    } catch (err) {
      console.error(err);
      alert("Failed to assign course.");
    } finally {
      setLoading(false);
    }
  };

  const filteredLecturers = lecturers.filter(l => l.category === selectedCategory);

  const categories = Array.from(new Set(lecturers.map(l => l.category)));

  return (
    <div className="flex min-h-screen bg-[#0A0A0A] text-[#f3f4f6]">
      <Sidebar />
      <main className="flex-1 ml-[18rem] p-10 pb-20 animate-in fade-in duration-700">
        <div className="mb-10">
          <h1 className="text-5xl font-black text-white uppercase italic tracking-tighter flex items-center gap-4">
            <Layers size={40} className="text-[#D4AF37]" />
            Course Assignments
          </h1>
          <p className="text-stone-400 mt-2 text-sm font-medium">
            Map departments, years, and courses to specific lecturers.
          </p>
        </div>

        {fetchingData ? (
          <div className="flex items-center justify-center h-64">
            <Loader2 className="animate-spin text-stone-500" size={32} />
          </div>
        ) : (
          <div className="max-w-4xl bg-[#161616] border border-[#2A2A2A] rounded-[2.5rem] p-8 backdrop-blur-xl">
            <form onSubmit={handleAssign} className="space-y-8">
              
              <div className="grid grid-cols-2 gap-6">
                {/* Department Selection */}
                <div className="space-y-2">
                  <label className="text-[10px] font-black uppercase tracking-widest text-stone-500 flex items-center gap-2">
                    <Building size={14} /> Academic Department
                  </label>
                  <select
                    value={selectedDept}
                    onChange={(e) => setSelectedDept(e.target.value)}
                    className="w-full bg-[#0A0A0A] border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-colors"
                    required
                  >
                    <option value="">Select Department</option>
                    {departments.map((department) => (
                      <option key={department} value={department}>{department}</option>
                    ))}
                  </select>
                </div>

                {/* Year Selection */}
                <div className="space-y-2">
                  <label className="text-[10px] font-black uppercase tracking-widest text-stone-500 flex items-center gap-2">
                    <Layers size={14} /> Year Level
                  </label>
                  <select
                    value={selectedYear}
                    onChange={(e) => setSelectedYear(e.target.value)}
                    className="w-full bg-[#0A0A0A] border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-colors"
                    required
                  >
                    <option value="">Select Year</option>
                    <option value="1st Year">1st Year</option>
                    <option value="2nd Year">2nd Year</option>
                    <option value="3rd Year">3rd Year</option>
                    <option value="4th Year">4th Year</option>
                    <option value="5th Year">5th Year</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-6">
                {/* Semester Selection */}
                <div className="space-y-2">
                  <label className="text-[10px] font-black uppercase tracking-widest text-stone-500 flex items-center gap-2">
                    <Layers size={14} /> Semester
                  </label>
                  <select
                    value={selectedSemester}
                    onChange={(e) => setSelectedSemester(e.target.value)}
                    className="w-full bg-[#0A0A0A] border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-colors"
                    required
                  >
                    <option value="">Select Semester</option>
                    <option value="1st Semester">1st Semester</option>
                    <option value="2nd Semester">2nd Semester</option>
                  </select>
                </div>

                {/* Section Selection */}
                <div className="space-y-2">
                  <label className="text-[10px] font-black uppercase tracking-widest text-stone-500 flex items-center gap-2">
                    <Users size={14} /> Section
                  </label>
                  <select
                    value={selectedSection}
                    onChange={(e) => setSelectedSection(e.target.value)}
                    className="w-full bg-[#0A0A0A] border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-colors"
                    required
                  >
                    <option value="">Select Section</option>
                    <option value="Section 1">Section 1</option>
                    <option value="Section 2">Section 2</option>
                    <option value="Section 3">Section 3</option>
                    <option value="Section 4">Section 4</option>
                    <option value="Section 5">Section 5</option>
                    <option value="Section 6">Section 6</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-6">
                {/* Group Selection */}
                <div className="space-y-2">
                  <label className="text-[10px] font-black uppercase tracking-widest text-stone-500 flex items-center gap-2">
                    <Users size={14} /> Student Group
                  </label>
                  <select
                    value={selectedGroup}
                    onChange={(e) => setSelectedGroup(e.target.value)}
                    className="w-full bg-[#0A0A0A] border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-colors"
                    required
                  >
                    <option value="Both">Both Groups</option>
                    <option value="Group 1">Group 1</option>
                    <option value="Group 2">Group 2</option>
                    <option value="Group 3">Group 3</option>
                    <option value="Group 4">Group 4</option>
                    <option value="Group 5">Group 5</option>
                    <option value="Group 6">Group 6</option>
                  </select>
                </div>

                {/* Course Code */}
                <div className="space-y-2">
                  <label className="text-[10px] font-black uppercase tracking-widest text-stone-500 flex items-center gap-2">
                    <BookOpen size={14} /> Course Code
                  </label>
                  <input
                    type="text"
                    value={courseCode}
                    onChange={(e) => setCourseCode(e.target.value)}
                    placeholder="e.g. CS101"
                    className="w-full bg-[#0A0A0A] border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-colors"
                    required
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 gap-6">
                {/* Course Title */}
                <div className="space-y-2">
                  <label className="text-[10px] font-black uppercase tracking-widest text-stone-500 flex items-center gap-2">
                    <BookOpen size={14} /> Course Title
                  </label>
                  <input
                    type="text"
                    value={courseTitle}
                    onChange={(e) => setCourseTitle(e.target.value)}
                    placeholder="e.g. Introduction to Programming"
                    className="w-full bg-[#0A0A0A] border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-colors"
                    required
                  />
                </div>
              </div>

              <div className="border-t border-[#2A2A2A] my-6"></div>

              <div className="grid grid-cols-2 gap-6">
                {/* Lecturer Category */}
                <div className="space-y-2">
                  <label className="text-[10px] font-black uppercase tracking-widest text-stone-500 flex items-center gap-2">
                    <Users size={14} /> Lecturer Category
                  </label>
                  <select
                    value={selectedCategory}
                    onChange={(e) => {
                      setSelectedCategory(e.target.value);
                      setSelectedLecturer(""); // Reset lecturer when category changes
                    }}
                    className="w-full bg-[#0A0A0A] border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-colors"
                    required
                  >
                    <option value="">Select Category</option>
                    {categories.map(c => (
                      <option key={c} value={c}>{c}</option>
                    ))}
                  </select>
                </div>

                {/* Specific Lecturer */}
                <div className="space-y-2">
                  <label className="text-[10px] font-black uppercase tracking-widest text-stone-500 flex items-center gap-2">
                    <Users size={14} /> Select Lecturer
                  </label>
                  <select
                    value={selectedLecturer}
                    onChange={(e) => setSelectedLecturer(e.target.value)}
                    className="w-full bg-[#0A0A0A] border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-colors"
                    required
                    disabled={!selectedCategory}
                  >
                    <option value="">Select Lecturer</option>
                    {filteredLecturers.map(l => (
                      <option key={l.id} value={l.id}>{l.name}</option>
                    ))}
                  </select>
                </div>
              </div>

              <div className="pt-4 flex justify-end">
                <button
                  type="submit"
                  disabled={loading}
                  className="bg-[#D4AF37] text-[#0A0A0A] px-8 py-4 rounded-xl font-black uppercase tracking-widest text-sm hover:bg-[#b08d2c] transition-all flex items-center gap-2 disabled:opacity-50"
                >
                  {loading ? (
                    <Loader2 size={18} className="animate-spin" />
                  ) : (
                    <>
                      <CheckCircle size={18} />
                      Assign Course
                    </>
                  )}
                </button>
              </div>

            </form>
          </div>
        )}
      </main>
    </div>
  );
}
