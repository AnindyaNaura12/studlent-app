class Config {
  static const supabaseUrl = "https://jjeaiiblywsmgdjpmowj.supabase.co";
  static const supabaseAnonKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpqZWFpaWJseXdzbWdkanBtb3dqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc3ODY2ODcsImV4cCI6MjA5MzM2MjY4N30.UYhai68XHqZbfc1U11---wA_S-w6MVnDu7Ju0fzD3do";
  // ── Laravel Base URL ──────────────────────────────────────
  // Browser (flutter run -d chrome) → http://127.0.0.1:8000/api
  // Android Emulator               → http://10.0.2.2:8000/api
  // Device fisik                   → http://192.168.x.x:8000/api
  static const laravelBaseUrl = 'http://127.0.0.1:8000/api'; // ← ganti sesuai env
}
    