import type { Metadata } from "next";
import "./globals.css";
import { AuthProvider } from "@/context/AuthContext";
import AdminGuard from "@/components/AdminGuard";

export const metadata: Metadata = {
  title: "CampusOne | Admin Command Center",
  description: "Campus Management Dashboard",
  icons: {
    icon: '/app_logo.png',
    shortcut: '/app_logo.png',
    apple: '/app_logo.png',
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="bg-[#0A0A0A] text-white">
        <AuthProvider>
          <AdminGuard>
            {children}
          </AdminGuard>
        </AuthProvider>
      </body>
    </html>
  );
}

