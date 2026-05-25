"use client";

import React, { useEffect, useState } from "react";
import { Sidebar } from "@/components/Sidebar";
import { collection, query, onSnapshot, orderBy, doc, addDoc, deleteDoc, serverTimestamp, where } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { 
  Calendar, 
  Loader2, 
  Plus, 
  Trash2, 
  Users, 
  Building2, 
  BookOpen, 
  Clock, 
  Save,
  LayoutGrid,
  FileSpreadsheet,
  Download,
  Upload,
  Copy,
  ToggleLeft,
  ToggleRight
} from "lucide-react";
import * as XLSX from "xlsx";

interface Allocation {
  group: string;
  students: number;
  block: string;
  room: string;
  status: string;
}

interface ExamDay {
  id: string;
  date: string;
  dayName: string;
  subject: string;
  courseCode: string;
  startTime: string;
  endTime: string;
  duration: string;
  invigilators: Record<string, { main: string; reserve: string }>;
}

interface ScheduleItem {
  id: string;
  dayIndex: number;
  startTime: string;
  endTime: string;
  subject: string;
  room: string;
  instructor: string;
  instructorId: string;
  cohort: string;
  section: string;
  type: 'class' | 'exam';
}

interface ScheduleData {
  academicYear: string;
  program: string;
  yearSemester: string; 
  cohort: string;       
  allocations: Allocation[];
  examDays: ExamDay[];
}

const DEPARTMENTS = [
  'Civil Engineering', 'Architecture', 'Water Resources Engineering',
  'Pre Engineering', 'Software Engineering', 'Computer Science Engineering',
  'Electrical Engineering', 'Mechanical Engineering', 'Material Engineering',
  'Chemical Engineering', 'Physics', 'Mathematics', 'ECE', 'EPE'
];
const YEARS = ['1st Year', '2nd Year', '3rd Year', '4th Year', '5th Year'];
const SEMESTERS = ['1st Semester', '2nd Semester'];
const ACADEMIC_YEARS = ['2024/2025', '2025/2026', '2026/2027'];
const DAYS = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

export default function SchedulesPage() {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [savedSchedules, setSavedSchedules] = useState<any[]>([]);
  const [mode, setMode] = useState<'exam' | 'class'>('exam');
  
  // Selection Header State
  const [academicYear, setAcademicYear] = useState(ACADEMIC_YEARS[1]);
  const [program, setProgram] = useState(DEPARTMENTS[0]);
  const [year, setYear] = useState(YEARS[1]);
  const [semester, setSemester] = useState(SEMESTERS[1]);
  const [section, setSection] = useState("Section 1");

  const yearSemester = `${year} (${semester})`;
  const cohort = `${year} ${program}`;

  // Exam State
  const [allocations, setAllocations] = useState<Allocation[]>([
    { group: "Group 1", students: 25, block: "Block A", room: "A-101", status: "Allocated" },
  ]);
  const [examDays, setExamDays] = useState<ExamDay[]>([
    { id: Date.now().toString(), date: "2026-05-11", dayName: "Monday", subject: "Technical Report Writing", courseCode: "EnLa2102", startTime: "02:00 PM", endTime: "05:00 PM", duration: "3 Hrs", invigilators: {} },
  ]);

  // Class State
  const [classItems, setClassItems] = useState<ScheduleItem[]>([
    { id: (Date.now() + 1).toString(), dayIndex: 0, startTime: "08:00 AM", endTime: "10:00 AM", subject: "Mathematics", room: "B-101", instructor: "Dr. Abebe", instructorId: "", cohort: cohort, section: section, type: 'class' },
  ]);

  // Excel Import State
  const [showPreview, setShowPreview] = useState(false);
  const [importData, setImportData] = useState<ScheduleData[]>([]);
  const [importErrors, setImportErrors] = useState<string[]>([]);

  useEffect(() => {
    const collectionName = mode === 'exam' ? "exam_schedules" : "schedules";
    const q = query(collection(db, collectionName), orderBy("createdAt", "desc"));
    const unsub = onSnapshot(q, (snap) => {
      setSavedSchedules(snap.docs.map(d => ({ ...d.data(), id: d.id })));
      setLoading(false);
    });
    return () => unsub();
  }, [mode]);

  const handleSave = async () => {
    setSaving(true);
    try {
      if (mode === 'exam') {
        await addDoc(collection(db, "exam_schedules"), {
          academicYear, program, yearSemester, cohort, section, allocations, examDays, createdAt: serverTimestamp()
        });
      } else {
        // Save class schedule items individually
        for (const item of classItems) {
          await addDoc(collection(db, "schedules"), {
            ...item,
            cohort,
            section,
            createdAt: serverTimestamp()
          });
        }
      }
      alert(`${mode === 'exam' ? 'Exam' : 'Class'} Schedule deployed successfully!`);
    } catch (e) {
      console.error(e);
      alert("Failed to save schedule");
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Delete this schedule?")) return;
    const collectionName = mode === 'exam' ? "exam_schedules" : "schedules";
    await deleteDoc(doc(db, collectionName, id));
  };

  // ─── EXCEL MULTI-SHEET MULTI-YEAR LOGIC ─────────────────────────────

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (evt) => {
      try {
        const bstr = evt.target?.result;
        const wb = XLSX.read(bstr, { type: 'binary' });
        const allSchedules: ScheduleData[] = [];
        const errors: string[] = [];

        // Parse every sheet in the workbook
        wb.SheetNames.forEach(sheetName => {
          const ws = wb.Sheets[sheetName];
          const data = XLSX.utils.sheet_to_json<any[]>(ws, { header: 1 });
          const schedules = parseASTUTemplateMultiYear(data, sheetName, errors);
          allSchedules.push(...schedules);
        });

        if (allSchedules.length === 0) {
          alert("Failed to extract any valid schedules from the file.");
          return;
        }

        setImportErrors(Array.from(new Set(errors)));
        setImportData(allSchedules);
        setShowPreview(true);
      } catch (err) {
        console.error(err);
        alert("Error parsing Excel file.");
      }
    };
    reader.readAsBinaryString(file);
    e.target.value = ''; // Reset file input
  };

  const parseASTUTemplateMultiYear = (rows: any[][], sheetName: string, errors: string[]): ScheduleData[] => {
    if (rows.length < 5) return [];

    let extractedSemester = "2nd Semester";
    let extractedAy = "2025/2026";
    let baseProgramName = sheetName.toUpperCase();

    // Map sheet names to standard department names
    const deptMap: Record<string, string> = {
      "CIVIL": "Civil Engineering",
      "ARCH": "Architecture",
      "WRE": "Water Resources Engineering",
      "PRE ENGINEERING": "Pre Engineering",
      "SOFTWARE": "Software Engineering",
    };
    
    // Try to find full department name from header rows
    const allText = rows.slice(0, 10).map(r => r.join(" ")).join("\n");
    for (const d of DEPARTMENTS) {
      if (allText.toLowerCase().includes(d.toLowerCase())) {
        baseProgramName = d;
        break;
      }
    }
    if (deptMap[sheetName.toUpperCase()]) {
      baseProgramName = deptMap[sheetName.toUpperCase()];
    }

    const semMatch = allText.match(/(\d+(st|nd|rd|th) Semester)/i);
    const ayMatch = allText.match(/(\d{4}\/\d{4})/);
    if (semMatch) extractedSemester = semMatch[0];
    if (ayMatch) extractedAy = ayMatch[0];

    // Find table columns
    let dateColIdx = 1, courseColIdx = 2, courseCodeColIdx = 3, groupColIdx = 4;
    let blockRoomColIdx = 5, mainInvigColIdx = 6, reserveInvigColIdx = 7;

    const schedules: ScheduleData[] = [];
    let currentYear = "";
    let allocationsMap = new Map();
    let examDaysMap = new Map();
    let lastValidDate = "";
    let lastValidCourse = "";
    let lastValidCourseCode = "";

    const flushCurrentSchedule = () => {
      if (currentYear && examDaysMap.size > 0) {
        const yearMatch = currentYear.match(/\d+(st|nd|rd|th) Year/i);
        const yLevel = yearMatch ? yearMatch[0] : "Unknown Year";
        
        schedules.push({
          academicYear: extractedAy,
          program: baseProgramName,
          yearSemester: `${yLevel} (${extractedSemester})`,
          cohort: `${yLevel} ${baseProgramName}`,
          allocations: Array.from(allocationsMap.values()),
          examDays: Array.from(examDaysMap.values())
        });
      }
      allocationsMap = new Map();
      examDaysMap = new Map();
      lastValidDate = "";
      lastValidCourse = "";
      lastValidCourseCode = "";
    };

    for (let i = 0; i < rows.length; i++) {
      const row = rows[i];
      if (!row || row.length === 0) continue;
      const rowStr = row.join(" ").trim();
      if (!rowStr) continue;

      if (rowStr.match(/\d+(st|nd|rd|th) Year/i) && row.length <= 4) {
        flushCurrentSchedule();
        currentYear = rowStr.trim();
        continue;
      }

      if (rowStr.toLowerCase().includes("course name") && rowStr.toLowerCase().includes("group")) {
        for (let j = 0; j < row.length; j++) {
          const cell = (row[j] || "").toString().toLowerCase().trim();
          if (cell === "group") groupColIdx = j;
          else if (cell.includes("date")) dateColIdx = j;
          else if (cell.includes("course code")) courseCodeColIdx = j;
          else if (cell.includes("course") || cell.includes("subject")) courseColIdx = j;
          else if (cell.includes("block") || cell.includes("room")) blockRoomColIdx = j;
          else if (cell.includes("main invigilator")) mainInvigColIdx = j;
          else if (cell.includes("reserve")) reserveInvigColIdx = j;
        }
        continue;
      }

      const rawDate = (row[dateColIdx]?.toString() || "").trim() || lastValidDate || "";
      const rawCourse = (row[courseColIdx]?.toString() || "").trim() || lastValidCourse || "";
      const rawCourseCode = (courseCodeColIdx !== -1 ? row[courseCodeColIdx]?.toString() : "")?.trim() || lastValidCourseCode || "";

      lastValidDate = rawDate;
      lastValidCourse = rawCourse;
      lastValidCourseCode = rawCourseCode;

      const groupNumRaw = (row[groupColIdx]?.toString() || "").trim();
      const blockAndRoom = blockRoomColIdx !== -1 ? (row[blockRoomColIdx]?.toString() || "").trim() : "TBD";
      const mainInvigilator = mainInvigColIdx !== -1 ? (row[mainInvigColIdx]?.toString() || "").trim() : "";
      const reserveInvigilator = reserveInvigColIdx !== -1 ? (row[reserveInvigColIdx]?.toString() || "").trim() : "";

      if (!groupNumRaw || !rawDate || !rawCourse || groupNumRaw.toLowerCase().includes("group")) continue;

      const groupName = groupNumRaw.toLowerCase().includes("group") ? groupNumRaw : `Group ${groupNumRaw}`;
      
      if (!allocationsMap.has(groupName)) {
        allocationsMap.set(groupName, {
          group: groupName, students: 25, block: "ASTU", room: blockAndRoom || "TBD", status: "Allocated"
        });
      }

      let parsedDate = rawDate, parsedStartTime = "09:00 AM", parsedEndTime = "12:00 PM", parsedDayName = "Unknown";
      const dayMatch = rawDate.match(/(monday|tuesday|wednesday|thursday|friday|saturday|sunday)/i);
      if (dayMatch) parsedDayName = dayMatch[0].charAt(0).toUpperCase() + dayMatch[0].slice(1).toLowerCase();

      const timeMatch = rawDate.match(/\d{1,2}:\d{2}\s*(AM|PM)?/i);
      if (timeMatch) {
        let timeStr = timeMatch[0].toUpperCase();
        if (!timeStr.includes('AM') && !timeStr.includes('PM')) {
           timeStr += (rawDate.toLowerCase().includes('afternoon') || rawDate.toLowerCase().includes('pm')) ? ' PM' : ' AM';
        }
        parsedStartTime = timeStr;
        let hour = parseInt(parsedStartTime.split(':')[0]);
        if (hour < 12 && parsedStartTime.includes('PM')) hour += 12;
        else if (hour === 12 && parsedStartTime.includes('AM')) hour = 0;
        let endHour = (hour + 3) % 24;
        const displayEndHour = endHour > 12 ? endHour - 12 : (endHour === 0 ? 12 : endHour);
        parsedEndTime = `${displayEndHour}:${parsedStartTime.split(':')[1].substring(0,2)} ${endHour >= 12 ? 'PM' : 'AM'}`;
      }

      const dateLines = rawDate.split('\n').map((s: string) => s.trim()).filter(Boolean);
      parsedDate = dateLines.length > 1 ? dateLines[0] : rawDate.replace(/\(?\s*(monday|tuesday|wednesday|thursday|friday|saturday|sunday)\s*\)?/gi, '').replace(/\d{1,2}:\d{2}\s*(AM|PM)?\s*(afternoon|morning)?/gi, '').replace(/^-|-$/g, '').trim();

      const dayKey = `${parsedDate}_${rawCourse}`;
      let examDayObj = examDaysMap.get(dayKey);
      if (!examDayObj) {
        examDayObj = { id: dayKey, date: parsedDate, dayName: parsedDayName, subject: rawCourse, courseCode: rawCourseCode, startTime: parsedStartTime, endTime: parsedEndTime, duration: "3 Hrs", invigilators: {} };
        examDaysMap.set(dayKey, examDayObj);
      }
      if (mainInvigilator || reserveInvigilator) examDayObj.invigilators[groupName] = { main: mainInvigilator, reserve: reserveInvigilator };
    }
    flushCurrentSchedule();
    return schedules;
  };

  const handleDownloadTemplate = () => {
    const ws = XLSX.utils.json_to_sheet([{"Academic Year": "2025-2026", "Department": "Software Engineering", "Year": "3rd Year", "Semester": "1st Semester", "Group": "Group A", "Subject": "Data Structures", "Exam Date": "2026-06-10", "Start Time": "09:00 AM", "End Time": "12:00 PM", "Block": "Block A", "Room": "A-101", "Students Count": 25}]);
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Template");
    XLSX.writeFile(wb, "CampusOne_Schedule_Template.xlsx");
  };

  const handleExport = () => {
    const data: any[] = [];
    allocations.forEach(a => examDays.forEach(d => data.push({"Academic Year": academicYear, "Department": program, "Year": yearSemester.split(' (')[0] || yearSemester, "Semester": yearSemester.split('(')[1]?.replace(')', '') || "", "Group": a.group, "Subject": d.subject, "Course Code": d.courseCode, "Exam Date": d.date, "Start Time": d.startTime, "End Time": d.endTime, "Block": a.block, "Room": a.room, "Students Count": a.students, "Main Invigilator": d.invigilators?.[a.group]?.main || "", "Reserve Invigilator": d.invigilators?.[a.group]?.reserve || ""})));
    XLSX.writeFile({SheetNames: ["Schedule_Export"], Sheets: {"Schedule_Export": XLSX.utils.json_to_sheet(data)}}, `Schedule_${program}_${yearSemester}.xlsx`);
  };

  const handleDuplicate = () => {
    if (savedSchedules.length > 0) {
      const last = savedSchedules[0];
      setAcademicYear(last.academicYear || ACADEMIC_YEARS[0]);
      setProgram(last.program || DEPARTMENTS[0]);
      if (last.allocations) setAllocations(last.allocations);
      if (last.examDays) setExamDays(last.examDays);
      alert("Loaded latest schedule allocations and exam days.");
    } else alert("No previous schedules found to duplicate.");
  };

  const handleAddClassItem = () => {
    setClassItems([...classItems, { 
      id: Date.now().toString(), 
      dayIndex: 0, 
      startTime: "08:00 AM", 
      endTime: "10:00 AM", 
      subject: "", 
      room: "", 
      instructor: "", 
      instructorId: "", 
      cohort: cohort, 
      section: section,
      type: 'class' 
    }]);
  };

  const confirmImport = async () => {
    if (importData.length === 0) return;
    setSaving(true);
    try {
      // Sanitize data to remove any 'undefined' values which Firestore doesn't support
      const sanitize = (obj: any): any => {
        return JSON.parse(JSON.stringify(obj, (key, value) => {
          return value === undefined ? null : value;
        }));
      };

      const promises = importData.map(sched => 
        addDoc(collection(db, "exam_schedules"), {
          ...sanitize(sched),
          createdAt: serverTimestamp()
        })
      );
      await Promise.all(promises);
      alert(`Successfully deployed ${importData.length} schedules!`);
      setShowPreview(false);
      setImportData([]);
    } catch (e) {
      console.error("Firebase Import Error:", e);
      alert("Failed to deploy some schedules. Check console for details.");
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="flex min-h-screen bg-[#0A0A0A] text-[#f3f4f6]">
      <Sidebar />
      <main className="flex-1 ml-[18rem] p-10 pb-20 space-y-8 animate-in fade-in duration-700">
        
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-4xl font-black text-white uppercase italic tracking-tighter flex items-center gap-4">
              <Calendar className="text-[#D4AF37]" size={32} />
              Schedule Management
            </h1>
            <div className="flex items-center gap-4 mt-2">
              <button 
                onClick={() => setMode('exam')}
                className={`px-4 py-1.5 rounded-full text-[10px] font-black uppercase tracking-widest transition-all ${mode === 'exam' ? 'bg-[#D4AF37] text-black' : 'bg-[#161616] text-stone-500 border border-[#2A2A2A]'}`}
              >
                Exam Mode
              </button>
              <button 
                onClick={() => setMode('class')}
                className={`px-4 py-1.5 rounded-full text-[10px] font-black uppercase tracking-widest transition-all ${mode === 'class' ? 'bg-blue-600 text-white' : 'bg-[#161616] text-stone-500 border border-[#2A2A2A]'}`}
              >
                Class Mode
              </button>
            </div>
          </div>
          <button 
            onClick={handleSave}
            disabled={saving}
            className={`flex items-center gap-2 px-8 py-3.5 rounded-2xl font-black uppercase tracking-widest text-sm transition-all shadow-lg ${mode === 'exam' ? 'bg-[#D4AF37] text-[#0A0A0A] shadow-[#D4AF37]/20' : 'bg-blue-600 text-white shadow-blue-600/20'}`}
          >
            {saving ? <Loader2 className="animate-spin" size={18} /> : <><Save size={18} /> Deploy {mode === 'exam' ? 'Exam' : 'Class'}</>}
          </button>
        </div>

        {/* Excel Toolbar */}
        <div className="flex flex-wrap items-center gap-4 bg-[#161616] p-4 rounded-2xl border border-[#2A2A2A]">
          <input type="file" id="excel-upload" accept=".xlsx, .xls" className="hidden" onChange={handleFileUpload} />
          
          <button onClick={() => document.getElementById('excel-upload')?.click()} className="flex items-center gap-2 bg-[#D4AF37]/10 text-[#D4AF37] border border-[#D4AF37]/20 px-5 py-2.5 rounded-xl text-xs font-black uppercase tracking-widest hover:bg-[#D4AF37] hover:text-black transition-all">
            <Upload size={16} /> Import Excel (Multi-Sheet)
          </button>
          
          <div className="h-6 w-px bg-[#2A2A2A] mx-2"></div>
          
          <button onClick={handleDownloadTemplate} className="flex items-center gap-2 bg-transparent text-stone-400 border border-[#2A2A2A] px-5 py-2.5 rounded-xl text-xs font-black uppercase tracking-widest hover:text-white hover:border-white/20 transition-all">
            <FileSpreadsheet size={16} /> Get Template
          </button>
          <button onClick={handleExport} className="flex items-center gap-2 bg-transparent text-stone-400 border border-[#2A2A2A] px-5 py-2.5 rounded-xl text-xs font-black uppercase tracking-widest hover:text-white hover:border-white/20 transition-all">
            <Download size={16} /> Export Data
          </button>
          <button onClick={handleDuplicate} className="flex items-center gap-2 bg-transparent text-stone-400 border border-[#2A2A2A] px-5 py-2.5 rounded-xl text-xs font-black uppercase tracking-widest hover:text-white hover:border-white/20 transition-all">
            <Copy size={16} /> Duplicate Prev
          </button>
        </div>

        {/* Common Filters */}
        <div className="bg-[#161616] border border-[#2A2A2A] rounded-[2.5rem] p-8">
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
              <div className="space-y-2">
                <label className="text-[10px] font-black text-stone-500 uppercase tracking-widest">Academic Year</label>
                <select value={academicYear} onChange={e => setAcademicYear(e.target.value)} className="w-full bg-black border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white outline-none">
                  {ACADEMIC_YEARS.map(y => <option key={y} value={y}>{y}</option>)}
                </select>
              </div>
              <div className="space-y-2">
                <label className="text-[10px] font-black text-stone-500 uppercase tracking-widest">Department</label>
                <select value={program} onChange={e => setProgram(e.target.value)} className="w-full bg-black border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white outline-none">
                  {DEPARTMENTS.map(d => <option key={d} value={d}>{d}</option>)}
                </select>
              </div>
              <div className="space-y-2">
                <label className="text-[10px] font-black text-stone-500 uppercase tracking-widest">Year Level</label>
                <select value={year} onChange={e => setYear(e.target.value)} className="w-full bg-black border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white outline-none">
                  {YEARS.map(y => <option key={y} value={y}>{y}</option>)}
                </select>
              </div>
              <div className="space-y-2">
                <label className="text-[10px] font-black text-stone-500 uppercase tracking-widest">Semester</label>
                <select value={semester} onChange={e => setSemester(e.target.value)} className="w-full bg-black border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white outline-none">
                  {SEMESTERS.map(s => <option key={s} value={s}>{s}</option>)}
                </select>
              </div>
              <div className="space-y-2">
                <label className="text-[10px] font-black text-stone-500 uppercase tracking-widest">Section</label>
                <select value={section} onChange={e => setSection(e.target.value)} className="w-full bg-black border border-[#2A2A2A] rounded-xl px-4 py-3 text-sm text-white outline-none">
                  <option value="Section 1">Section 1</option>
                  <option value="Section 2">Section 2</option>
                  <option value="Section 3">Section 3</option>
                  <option value="Section 4">Section 4</option>
                  <option value="Section 5">Section 5</option>
                  <option value="Section 6">Section 6</option>
                </select>
              </div>
            </div>
            <div className="mt-4 p-3 rounded-xl bg-white/5 border border-white/10 inline-block flex gap-4">
              <p className="text-xs text-stone-400 font-bold">Target Cohort: <span className="text-white">{cohort}</span></p>
              <p className="text-xs text-stone-400 font-bold">Target Section: <span className="text-white">{section}</span></p>
            </div>
        </div>

        {mode === 'exam' ? (
          /* EXAM MODE UI */
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div className="lg:col-span-2 space-y-8">
              <div className="bg-[#161616] border border-[#2A2A2A] rounded-[2.5rem] p-8">
                <div className="flex justify-between mb-6">
                  <h2 className="text-xl font-black text-white uppercase tracking-tight">Allocations</h2>
                  <button onClick={() => setAllocations([...allocations, { group: `Group ${allocations.length + 1}`, students: 25, block: "", room: "", status: "Pending" }])} className="text-[10px] font-black text-[#D4AF37] uppercase">+ Add Group</button>
                </div>
                <table className="w-full text-xs">
                  <thead><tr className="text-left text-stone-500 uppercase font-black tracking-widest border-b border-[#2A2A2A]"><th className="pb-3">Group</th><th className="pb-3">Block</th><th className="pb-3">Room</th><th className="pb-3 text-right">Students</th></tr></thead>
                  <tbody>
                    {allocations.map((a, i) => (
                      <tr key={i} className="border-b border-white/[0.02]">
                        <td className="py-3"><input value={a.group} onChange={e => {const n=[...allocations]; n[i].group=e.target.value; setAllocations(n);}} className="bg-transparent text-white font-bold outline-none w-24"/></td>
                        <td className="py-3"><input value={a.block} onChange={e => {const n=[...allocations]; n[i].block=e.target.value; setAllocations(n);}} className="bg-black/40 border border-[#2A2A2A] rounded px-2 py-1 outline-none w-20"/></td>
                        <td className="py-3"><input value={a.room} onChange={e => {const n=[...allocations]; n[i].room=e.target.value; setAllocations(n);}} className="bg-black/40 border border-[#2A2A2A] rounded px-2 py-1 outline-none w-20"/></td>
                        <td className="py-3 text-right"><input type="number" value={a.students} onChange={e => {const n=[...allocations]; n[i].students=parseInt(e.target.value); setAllocations(n);}} className="bg-transparent text-right text-stone-400 w-12"/></td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
              
              <div className="bg-[#161616] border border-[#2A2A2A] rounded-[2.5rem] p-8">
                <div className="flex justify-between mb-6">
                  <h2 className="text-xl font-black text-white uppercase tracking-tight">Exam Days</h2>
                  <button onClick={() => setExamDays([...examDays, { id: Date.now().toString(), date: "", dayName: "", subject: "", courseCode: "", startTime: "09:00 AM", endTime: "12:00 PM", duration: "3 Hrs", invigilators: {} }])} className="text-[10px] font-black text-purple-400 uppercase">+ Add Day</button>
                </div>
                <table className="w-full text-xs">
                  <thead><tr className="text-left text-stone-500 uppercase font-black tracking-widest border-b border-[#2A2A2A]"><th className="pb-3">Date</th><th className="pb-3">Subject</th><th className="pb-3">Code</th><th className="pb-3 text-right">Time</th></tr></thead>
                  <tbody>
                    {examDays.map((d, i) => (
                      <tr key={d.id} className="border-b border-white/[0.02]">
                        <td className="py-3"><input value={d.date} onChange={e => {const n=[...examDays]; n[i].date=e.target.value; setExamDays(n);}} className="bg-transparent text-white font-bold outline-none w-20"/></td>
                        <td className="py-3"><input value={d.subject} onChange={e => {const n=[...examDays]; n[i].subject=e.target.value; setExamDays(n);}} className="bg-transparent text-white outline-none w-40"/></td>
                        <td className="py-3"><input value={d.courseCode} onChange={e => {const n=[...examDays]; n[i].courseCode=e.target.value; setExamDays(n);}} className="bg-transparent text-stone-400 outline-none w-16"/></td>
                        <td className="py-3 text-right"><input value={d.startTime} onChange={e => {const n=[...examDays]; n[i].startTime=e.target.value; setExamDays(n);}} className="bg-transparent text-right text-stone-400 w-20"/></td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
            <div className="bg-[#161616] border border-[#2A2A2A] rounded-[2.5rem] p-8">
              <h3 className="text-xs font-black text-white uppercase tracking-widest mb-6">Saved Exam Schedules</h3>
              <div className="space-y-3">
                {savedSchedules.map(s => (
                  <div key={s.id} className="p-4 bg-black/40 border border-[#2A2A2A] rounded-2xl group">
                    <div className="flex justify-between items-start mb-2">
                      <p className="text-[9px] font-black text-stone-500 uppercase tracking-widest">{s.program}</p>
                      <button onClick={() => handleDelete(s.id)} className="text-rose-500 opacity-0 group-hover:opacity-100"><Trash2 size={12}/></button>
                    </div>
                    <p className="text-xs font-bold text-white">{s.cohort}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        ) : (
          /* CLASS MODE UI */
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div className="lg:col-span-2 bg-[#161616] border border-[#2A2A2A] rounded-[2.5rem] p-8">
               <div className="flex justify-between mb-8">
                  <h2 className="text-xl font-black text-white uppercase tracking-tight">Weekly Timetable</h2>
                  <button onClick={handleAddClassItem} className="flex items-center gap-2 bg-blue-600/10 text-blue-500 px-4 py-2 rounded-xl text-[10px] font-black uppercase tracking-widest hover:bg-blue-600 hover:text-white transition-all">
                    <Plus size={14}/> Add Class
                  </button>
               </div>
               <div className="space-y-4">
                 {classItems.map((item, i) => (
                   <div key={item.id} className="grid grid-cols-1 md:grid-cols-6 gap-4 p-4 bg-black/40 border border-[#2A2A2A] rounded-2xl items-end relative group">
                     <button onClick={() => setClassItems(classItems.filter(c => c.id !== item.id))} className="absolute top-2 right-2 text-stone-600 hover:text-red-500 opacity-0 group-hover:opacity-100 transition-all">
                       <Trash2 size={14}/>
                     </button>
                     <div className="space-y-1">
                       <label className="text-[9px] font-black text-stone-600 uppercase">Day</label>
                       <select value={item.dayIndex} onChange={e => {const n=[...classItems]; n[i].dayIndex=parseInt(e.target.value); setClassItems(n);}} className="w-full bg-[#161616] border border-[#2A2A2A] rounded-lg px-2 py-2 text-xs text-white outline-none">
                         {DAYS.map((d, idx) => <option key={d} value={idx}>{d}</option>)}
                       </select>
                     </div>
                     <div className="md:col-span-2 space-y-1">
                       <label className="text-[9px] font-black text-stone-600 uppercase">Subject / Course</label>
                       <input value={item.subject} onChange={e => {const n=[...classItems]; n[i].subject=e.target.value; setClassItems(n);}} className="w-full bg-[#161616] border border-[#2A2A2A] rounded-lg px-3 py-2 text-xs text-white outline-none" placeholder="e.g. Algorithms"/>
                     </div>
                     <div className="space-y-1">
                       <label className="text-[9px] font-black text-stone-600 uppercase">Time</label>
                       <input value={item.startTime} onChange={e => {const n=[...classItems]; n[i].startTime=e.target.value; setClassItems(n);}} className="w-full bg-[#161616] border border-[#2A2A2A] rounded-lg px-2 py-2 text-xs text-white outline-none" placeholder="08:00 AM"/>
                     </div>
                     <div className="space-y-1">
                       <label className="text-[9px] font-black text-stone-600 uppercase">Room</label>
                       <input value={item.room} onChange={e => {const n=[...classItems]; n[i].room=e.target.value; setClassItems(n);}} className="w-full bg-[#161616] border border-[#2A2A2A] rounded-lg px-2 py-2 text-xs text-white outline-none" placeholder="B-101"/>
                     </div>
                     <div className="space-y-1">
                       <label className="text-[9px] font-black text-stone-600 uppercase">Instructor Name</label>
                       <input value={item.instructor} onChange={e => {const n=[...classItems]; n[i].instructor=e.target.value; setClassItems(n);}} className="w-full bg-[#161616] border border-[#2A2A2A] rounded-lg px-2 py-2 text-xs text-white outline-none" placeholder="Dr. Abebe"/>
                     </div>
                   </div>
                 ))}
                 {classItems.length === 0 && (
                   <div className="py-20 text-center text-stone-700">
                     <p className="text-[10px] font-black uppercase tracking-widest">No classes added yet</p>
                   </div>
                 )}
               </div>
            </div>
            <div className="bg-[#161616] border border-[#2A2A2A] rounded-[2.5rem] p-8">
               <h3 className="text-sm font-black text-white uppercase tracking-widest mb-6">Recent Class Schedules</h3>
               <div className="space-y-3">
                 {savedSchedules.map(s => (
                   <div key={s.id} className="p-4 bg-black/40 border border-[#2A2A2A] rounded-2xl flex justify-between items-center group">
                      <div>
                        <p className="text-[10px] font-black text-blue-500 uppercase tracking-widest">{DAYS[s.dayIndex]}</p>
                        <p className="text-xs font-bold text-white">{s.subject}</p>
                        <p className="text-[9px] text-stone-600 font-black uppercase">{s.cohort}</p>
                      </div>
                      <button onClick={() => handleDelete(s.id)} className="text-rose-500 opacity-0 group-hover:opacity-100 transition-all">
                        <Trash2 size={14}/>
                      </button>
                   </div>
                 ))}
               </div>
            </div>
          </div>
        )}

        {/* Validation Modal (Multi-Sheet Import) */}
        {showPreview && importData.length > 0 && (
          <div className="fixed inset-0 z-[100] bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
             <div className="bg-[#161616] border border-[#2A2A2A] rounded-3xl p-8 max-w-4xl w-full max-h-[90vh] overflow-y-auto">
               <h2 className="text-2xl font-black text-white uppercase tracking-tight mb-2">Preview Excel Import</h2>
               <p className="text-stone-400 text-sm mb-6">Found {importData.length} schedules across multiple departments and years.</p>
               
               {importErrors.length > 0 && (
                 <div className="bg-red-500/10 border border-red-500/20 p-4 rounded-xl mb-6">
                   <h3 className="text-red-500 font-bold mb-2">Conflicts Detected ({importErrors.length})</h3>
                   <ul className="text-sm text-red-400 space-y-1 list-disc pl-4 max-h-32 overflow-y-auto">
                     {importErrors.map((e, i) => <li key={i}>{e}</li>)}
                   </ul>
                 </div>
               )}

               <div className="space-y-4 mb-8">
                 <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    {importData.map((sched, idx) => (
                      <div key={idx} className="bg-black/50 p-4 rounded-xl border border-[#2A2A2A]">
                        <p className="text-[10px] font-black text-[#D4AF37] uppercase tracking-widest mb-1">{sched.program}</p>
                        <p className="text-white text-sm font-bold">{sched.yearSemester}</p>
                        <p className="text-stone-500 text-xs mt-1">{sched.cohort}</p>
                        <div className="mt-3 pt-3 border-t border-[#2A2A2A] flex justify-between text-xs">
                          <span className="text-stone-400">{sched.allocations.length} Groups</span>
                          <span className="text-stone-400">{sched.examDays.length} Days</span>
                        </div>
                      </div>
                    ))}
                 </div>
               </div>

               <div className="flex gap-4 justify-end border-t border-[#2A2A2A] pt-6">
                 <button onClick={() => {setShowPreview(false); setImportData([]);}} className="px-6 py-3 rounded-xl text-stone-400 font-bold hover:bg-white/10 hover:text-white transition-colors">Cancel</button>
                 <button 
                   onClick={confirmImport} 
                   disabled={saving} 
                   className="px-6 py-3 rounded-xl bg-[#D4AF37] flex items-center gap-2 text-black font-black uppercase tracking-widest hover:bg-[#b08d2c] disabled:opacity-50 disabled:cursor-not-allowed transition-all"
                 >
                   {saving ? <Loader2 className="animate-spin" size={16} /> : null}
                   Deploy All {importData.length} Schedules
                 </button>
               </div>
             </div>
          </div>
        )}
      </main>
    </div>
  );
}
