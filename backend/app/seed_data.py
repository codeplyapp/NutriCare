import json
from sqlalchemy.orm import Session
from app.core.database import SessionLocal
from app.models.models import Doctor, Article, User, StudyModule, Flashcard, QuizQuestion
from app.core.security import get_password_hash

def seed_initial_data():
    db: Session = SessionLocal()
    try:
        # Seed Doctors
        if db.query(Doctor).count() == 0:
            sample_doctors = [
                Doctor(
                    name="dr. Sarah Wijaya, Sp.GK",
                    specialty="Spesialis Gizi Klinis (Metabolik & Diet)",
                    affiliation="RSUP Sanglah / RSU Bali",
                    rating=4.9,
                    photo_url="https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300",
                    fee=75000,
                    available_days="Senin - Jumat, 09:00 - 15:00",
                    is_available=True
                ),
                Doctor(
                    name="dr. Budi Santoso, M.Gizi, Sp.GK",
                    specialty="Spesialis Gizi Olahraga & Kebugaran",
                    affiliation="Puskesmas Denpasar Selatan",
                    rating=4.8,
                    photo_url="https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=300",
                    fee=50000,
                    available_days="Selasa & Kamis, 13:00 - 18:00",
                    is_available=True
                ),
                Doctor(
                    name="dr. Ni Made Ayu Pramesti, Sp.A, M.Kes",
                    specialty="Spesialis Gizi & Tumbuh Kembang Anak",
                    affiliation="RSUD Wangaya",
                    rating=5.0,
                    photo_url="https://images.unsplash.com/photo-1594824813637-4384918e6ec3?auto=format&fit=crop&q=80&w=300",
                    fee=85000,
                    available_days="Senin, Rabu, Jumat, 10:00 - 16:00",
                    is_available=True
                )
            ]
            db.add_all(sample_doctors)
            db.commit()

        # Seed Articles
        if db.query(Article).count() == 0:
            sample_articles = [
                Article(
                    title="Panduan Lengkap Piring Makan Gizi Seimbang (Isi Piringku)",
                    category="Gizi Harian",
                    summary="Mengenal komposisi 50% sayur-buah, 25% karbohidrat, dan 25% lauk protein sesuai pedoman Kemenkes RI.",
                    content=(
                        "Pedoman 'Isi Piringku' adalah panduan visual yang dirancang oleh Kementerian Kesehatan Republik Indonesia "
                        "untuk membantu masyarakat menyajikan makanan dengan gizi seimbang dalam satu porsi makan.\n\n"
                        "### 1. Setengah Piring: Sayur dan Buah\n"
                        "- 2/3 dari setengah piring diisi oleh aneka sayuran (bayam, brokoli, wortel).\n"
                        "- 1/3 dari setengah piring diisi oleh buah-buahan segar (pepaya, pisang, jeruk, apel).\n\n"
                        "### 2. Setengah Piring Lainnya: Makanan Pokok & Lauk Pauk\n"
                        "- 2/3 diisi sumber karbohidrat kompleks seperti nasi merah, jagung, atau ubi jalar.\n"
                        "- 1/3 diisi sumber protein berkualitas tinggi, baik hewani (ikan kembung, ayam tanpa kulit) maupun nabati (tahu, tempe, edamame).\n\n"
                        "Jangan lupa mencukupi asupan air putih minimal 8 gelas per hari dan mencuci tangan dengan sabun sebelum makan."
                    ),
                    content_url="https://kemkes.go.id",
                    image_url="https://images.unsplash.com/photo-1498837167922-ddd27525d352?auto=format&fit=crop&q=80&w=600",
                    read_time_minutes=4
                ),
                Article(
                    title="Pentingnya Hidrasi Tubuh & Cara Memenuhi Target Air Harian",
                    category="Hidrasi",
                    summary="Bagaimana kekurangan cairan mempengaruhi fokus kerja dan metabolisme, serta tips pintar minum tepat waktu.",
                    content=(
                        "Air membentuk sekitar 60% dari total berat tubuh manusia dan memegang peranan krusial dalam mengatur suhu tubuh, "
                        "melancarkan sirkulasi darah, serta membuang sisa racun metabolik.\n\n"
                        "### Berapa Banyak Air yang Dibutuhkan?\n"
                        "Rumus standar yang dianjurkan oleh ahli gizi klinis adalah sekitar 30-35 ml per kilogram berat badan. "
                        "Jika berat Anda 60 kg, kebutuhan cairan minimal Anda adalah sekitar 1.800 - 2.100 ml per hari.\n\n"
                        "### Gejala Dehidrasi Ringan:\n"
                        "- Sakit kepala atau pusing di siang hari\n"
                        "- Rasa lemas dan penurunan konsentrasi saat bekerja\n"
                        "- Warna urine kuning pekat\n\n"
                        "Gunakan integrasi jam pintar NutriCare untuk menerima pengingat getar berkala agar Anda selalu terhidrasi optimal!"
                    ),
                    content_url="https://kemkes.go.id",
                    image_url="https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=800",
                    read_time_minutes=3
                ),
                Article(
                    title="Tips Pola Makan Sehat untuk Menstabilkan Gula Darah",
                    category="Penyakit Kronis",
                    summary="Strategi praktis mengatur indeks glikemik makanan dan frekuensi makan teratur untuk pencegahan diabetes.",
                    content=(
                        "Mengontrol fluktuasi gula darah adalah kunci pencegahan dan manajemen resistensi insulin maupun diabetes melitus.\n\n"
                        "### Prinsip Utama:\n"
                        "1. **Pilih Karbohidrat Berindeks Glikemik Rendah**: Gantilah nasi putih dengan nasi merah, oat utuh, atau quinoa.\n"
                        "2. **Kombinasikan dengan Serat & Protein**: Serat memperlambat penyerapan glukosa ke dalam aliran darah sehingga mencegah lonjakan gula drastis.\n"
                        "3. **Hindari Minuman Manis Berpemanis Buatan**: Gula cair diserap tubuh dalam hitungan menit dan memicu lonjakan insulin yang tinggi.\n\n"
                        "Bila Anda memiliki riwayat diabetes keluarga, konsultasikan menu harian Anda dengan dokter gizi kami lewat menu Konsultasi Dokter."
                    ),
                    content_url="https://kemkes.go.id",
                    image_url="https://images.unsplash.com/photo-1505576399279-565b52d4ac71?auto=format&fit=crop&q=80&w=600",
                    read_time_minutes=5
                )
            ]
            db.add_all(sample_articles)
            db.commit()

        # Seed Curriculum Study Modules (FASE 2)
        if db.query(StudyModule).count() == 0:
            modules_data = [
                {
                    "title": "Pondasi Gizi Seimbang & Isi Piringku",
                    "category": "Dasar Gizi",
                    "level_order": 1,
                    "icon_name": "restaurant_menu",
                    "estimated_minutes": 10,
                    "description": "Memahami kaidah makronutrien, mikronutrien, dan proporsi Isi Piringku Kemenkes RI.",
                    "content": (
                        "# Pondasi Gizi Seimbang & Prinsip Isi Piringku\n\n"
                        "Gizi seimbang adalah susunan pangan sehari-hari yang mengandung zat gizi dalam jenis dan jumlah yang sesuai dengan kebutuhan tubuh.\n\n"
                        "## 1. Tiga Pilar Makronutrien Utama\n"
                        "- **Karbohidrat (4 kkal/g)**: Sumber bahan bakar utama otak dan otot tubuh.\n"
                        "- **Protein (4 kkal/g)**: Blok pembangun sel, pemulihan jaringan, enzim, dan antibodi sistem imun.\n"
                        "- **Lemak Sehat (9 kkal/g)**: Pelindung organ, pembentuk hormon, dan pelarut vitamin A, D, E, K.\n\n"
                        "## 2. Panduan Visual Isi Piringku (Kemenkes RI)\n"
                        "Dalam satu piring makan:\n"
                        "1. **50% Piring**: Sayuran segar (2/3) dan Buah-buahan (1/3).\n"
                        "2. **50% Piring Lainnya**: Makanan pokok karbohidrat kompleks (2/3) dan Lauk hewani/nabati (1/3)."
                    ),
                    "flashcards": [
                        {"term": "Makronutrien", "definition": "Nutrisi makro yang dibutuhkan tubuh dalam jumlah besar (Karbohidrat, Protein, Lemak) untuk energi metabolik.", "tip": "Pastikan rasio makronutrien Anda seimbang setiap kali makan."},
                        {"term": "Isi Piringku", "definition": "Panduan visual resmi Kemenkes: 50% piring sayur & buah, 50% makanan pokok & lauk berprotein.", "tip": "Gunakan piring standar 20-22 cm untuk kontrol porsi yang akurat."},
                        {"term": "BMR (Basal Metabolic Rate)", "definition": "Jumlah kalori minimum yang dibutuhkan tubuh untuk menjalankan fungsi vital dasar dalam keadaan istirahat total.", "tip": "Dihitung secara presisi lewat formula Mifflin-St Jeor di NutriCare."}
                    ],
                    "quiz": [
                        {
                            "question": "Berapa persen porsi sayur dan buah yang direkomendasikan dalam panduan 'Isi Piringku' Kemenkes?",
                            "options": ["25% dari piring", "33% dari piring", "50% dari piring", "75% dari piring"],
                            "correct_index": 2,
                            "explanation": "Panduan Isi Piringku Kemenkes menetapkan separuh piring (50%) diisi oleh kombinasi sayuran dan buah-buahan.",
                            "is_case_study": False
                        },
                        {
                            "question": "Berapa energi yang dihasilkan oleh 1 gram lemak dalam tubuh?",
                            "options": ["4 kkal", "7 kkal", "9 kkal", "12 kkal"],
                            "correct_index": 2,
                            "explanation": "Lemak menghasilkan 9 kkal per gram, lebih dari dua kali lipat karbohidrat dan protein (masing-masing 4 kkal per gram).",
                            "is_case_study": False
                        },
                        {
                            "question": "Studi Kasus: Budi (berat 70 kg) ingin menghitung kebutuhan air harian minimalnya. Berapakah volume air yang ideal?",
                            "options": ["1.000 ml", "1.500 ml", "2.100 - 2.450 ml", "3.500 ml"],
                            "correct_index": 2,
                            "explanation": "Rekomendasi kebutuhan cairan standar adalah 30-35 ml per kg berat badan. Untuk 70 kg = 70 × 30-35 = 2.100 - 2.450 ml per hari.",
                            "is_case_study": True
                        }
                    ]
                },
                {
                    "title": "Manajemen Diet Diabetes & Kontrol Glikemik",
                    "category": "Diabetes",
                    "level_order": 2,
                    "icon_name": "bloodtype",
                    "estimated_minutes": 12,
                    "description": "Strategi penerapan Prinsip 3J dan pengendalian respon glukosa darah harian.",
                    "content": (
                        "# Manajemen Diet Diabetes Mellitus\n\n"
                        "Kunci sukses manajemen diabetes adalah menjaga stabilitas kadar glukosa darah agar terhindar dari lonjakan hiperglikemia maupun hipoglikemia.\n\n"
                        "## Prinsip Diet 3J\n"
                        "1. **Tepat Jadwal**: Makan 3 kali utama dan 2-3 kali selingan ringan pada jam yang konsisten.\n"
                        "2. **Tepat Jumlah**: Asupan kalori disesuaikan dengan status gizi dan aktivitas fisik.\n"
                        "3. **Tepat Jenis**: Memilih sumber karbohidrat berindeks glikemik rendah (<55) dan tinggi serat larut."
                    ),
                    "flashcards": [
                        {"term": "Indeks Glikemik (IG)", "definition": "Ukuran seberapa cepat karbohidrat dalam makanan diubah menjadi glukosa darah.", "tip": "Pilihlah makanan IG rendah seperti beras merah, oat, dan kacang-kacangan."},
                        {"term": "Prinsip 3J", "definition": "Aturan dasar diet diabetes: Tepat Jadwal, Tepat Jumlah kalori, dan Tepat Jenis makanan.", "tip": "Konsistensi jam makan mencegah lonjakan insulin mendadak."},
                        {"term": "Serat Larut Air", "definition": "Serat yang membentuk gel di usus dan memperlambat penyerapan glukosa darah.", "tip": "Terdapat melimpah pada apel, oatmeal, dan chia seed."}
                    ],
                    "quiz": [
                        {
                            "question": "Prinsip 3J dalam tata laksana diet diabetes mencakup apa saja?",
                            "options": ["Jarak, Jumlah, Jamu", "Jadwal, Jumlah, Jenis", "Jus, Jam, Jenuh", "Jenuh, Jumlah, Jantung"],
                            "correct_index": 1,
                            "explanation": "Prinsip 3J Kemenkes terdiri dari Tepat Jadwal, Tepat Jumlah, dan Tepat Jenis.",
                            "is_case_study": False
                        },
                        {
                            "question": "Makanan karbohidrat manakah yang memiliki Indeks Glikemik (IG) paling rendah?",
                            "options": ["Nasi putih pulen", "Roti tawar putih", "Oatmeal utuh (Rolled Oats)", "Semangka matang"],
                            "correct_index": 2,
                            "explanation": "Rolled oats memiliki IG rendah (~50) dan kaya serat beta-glukan yang menstabilkan glukosa darah.",
                            "is_case_study": False
                        }
                    ]
                },
                {
                    "title": "Diet DASH & Pencegahan Hipertensi",
                    "category": "Hipertensi",
                    "level_order": 3,
                    "icon_name": "favorite",
                    "estimated_minutes": 10,
                    "description": "Mengontrol tekanan darah melalui diet rendah natrium dan kaya kalium-magnesium.",
                    "content": (
                        "# Diet DASH (Dietary Approaches to Stop Hypertension)\n\n"
                        "Diet DASH terbukti secara klinis mampu menurunkan tekanan darah sistolik dan diastolik secara signifikan dalam 2-4 minggu.\n\n"
                        "## Batasan Natrium Kemenkes RI\n"
                        "- Maksimal **2.000 mg natrium** per hari (setara 1 sendok teh garam dapur / 5 gram garam).\n"
                        "- Waspadai garam tersembunyi pada makanan olahan, kecap, saus instan, dan makanan kaleng."
                    ),
                    "flashcards": [
                        {"term": "Diet DASH", "definition": "Pola makan ilmiah untuk menurunkan hipertensi dengan memperbanyak kalium, kalsium, magnesium dan membatasi natrium.", "tip": "Perbanyak pisang, alpukat, sayuran hijau, dan susu rendah lemak."},
                        {"term": "Batas Natrium", "definition": "Maksimal 2.000 mg natrium atau 1 sendok teh garam dapur per hari per orang.", "tip": "Gunakan rempah alami seperti bawang putih dan ketumbar sebagai pengganti garam berlebih."}
                    ],
                    "quiz": [
                        {
                            "question": "Berapa batas konsumsi natrium maksimal harian yang dianjurkan Kemenkes RI?",
                            "options": ["1.000 mg (1/2 sdt garam)", "2.000 mg (1 sdt garam)", "4.000 mg (2 sdt garam)", "5.000 mg (2.5 sdt garam)"],
                            "correct_index": 1,
                            "explanation": "Kemenkes merekomendasikan batas aman natrium 2.000 mg per hari atau setara dengan 1 sendok teh garam dapur.",
                            "is_case_study": False
                        }
                    ]
                },
                {
                    "title": "Nutrisi Ibu, Anak & Pencegahan Stunting",
                    "category": "Ibu & Anak",
                    "level_order": 4,
                    "icon_name": "child_care",
                    "estimated_minutes": 12,
                    "description": "Pemenuhan gizi 1000 HPK, ASI eksklusif, dan MPASI kaya protein hewani pencegah stunting.",
                    "content": (
                        "# Nutrisi 1000 Hari Pertama Kehidupan (HPK)\n\n"
                        "Periode 1000 HPK dimulai sejak janin terbentuk dalam kandungan (270 hari) hingga anak berusia 2 tahun (730 hari).\n\n"
                        "## Kunci Pencegahan Stunting\n"
                        "1. **Pemberian ASI Eksklusif** selama 6 bulan pertama tanpa tambahan makanan/minuman lain.\n"
                        "2. **MPASI Berkualitas**: Wajib menyertakan sumber protein hewani (telur, hati ayam, ikan kembung) setiap kali makan."
                    ),
                    "flashcards": [
                        {"term": "1000 HPK", "definition": "Periode emas tumbuh kembang otak dan organ tubuh dari konsepsi hingga usia 2 tahun.", "tip": "Kekurangan gizi di masa ini bersifat permanen dan sulit diperbaiki di kemudian hari."},
                        {"term": "Protein Hewani", "definition": "Sumber asam amino esensial lengkap dengan bioavailabilitas tinggi untuk pertumbuhan linear tulang anak.", "tip": "Satu butir telur per hari sangat efektif menunjang pertumbuhan tinggi badan balita."}
                    ],
                    "quiz": [
                        {
                            "question": "Berapa lama durasi ASI Eksklusif yang dianjurkan secara medis oleh Kemenkes & WHO?",
                            "options": ["3 bulan", "6 bulan", "9 bulan", "12 bulan"],
                            "correct_index": 1,
                            "explanation": "ASI Eksklusif diberikan selama 6 bulan pertama kehidupan bayi tanpa tambahan makanan atau air lainnya.",
                            "is_case_study": False
                        }
                    ]
                },
                {
                    "title": "Nutrisi Olahraga & Kebugaran Atletik",
                    "category": "Olahraga",
                    "level_order": 5,
                    "icon_name": "fitness_center",
                    "estimated_minutes": 10,
                    "description": "Pengaturan makro untuk performa fisik, pemulihan glikogen, dan sintesis protein otot.",
                    "content": (
                        "# Nutrisi Olahraga & Pembentukan Massa Otot\n\n"
                        "Nutrisi yang tepat memaksimalkan performa latihan fisik dan mempercepat regenerasi serabut otot yang rusak.\n\n"
                        "## Kebutuhan Protein Harian\n"
                        "- Individu Sedentary: 0.8 - 1.0 g / kgBB.\n"
                        "- Atlet Daya Tahan (Endurance): 1.2 - 1.4 g / kgBB.\n"
                        "- Latihan Beban (Hypertrophy): 1.6 - 2.2 g / kgBB."
                    ),
                    "flashcards": [
                        {"term": "Sintesis Protein Otot", "definition": "Proses biologis pembentukan serat otot baru pasca stimulasi latihan beban.", "tip": "Distribusikan asupan protein 20-30g per waktu makan untuk stimulasi optimal."},
                        {"term": "Glikogen Otot", "definition": "Bentuk cadangan glukosa yang tersimpan di otot dan hati sebagai bahan bakar olahraga intensif.", "tip": "Konsumsi karbohidrat kompleks 1-2 jam sebelum latihan intensif."}
                    ],
                    "quiz": [
                        {
                            "question": "Berapakah anjuran asupan protein harian untuk individu yang aktif melakukan latihan beban pembentukan otot?",
                            "options": ["0.5 - 0.8 g/kgBB", "0.8 - 1.0 g/kgBB", "1.6 - 2.2 g/kgBB", "3.5 - 4.5 g/kgBB"],
                            "correct_index": 2,
                            "explanation": "Rekomendasi berbasis bukti ilmiah untuk hipertrofi otot adalah 1.6 - 2.2 gram protein per kilogram berat badan per hari.",
                            "is_case_study": False
                        }
                    ]
                }
            ]

            for m_dict in modules_data:
                mod = StudyModule(
                    title=m_dict["title"],
                    category=m_dict["category"],
                    level_order=m_dict["level_order"],
                    icon_name=m_dict["icon_name"],
                    estimated_minutes=m_dict["estimated_minutes"],
                    description=m_dict["description"],
                    content=m_dict["content"]
                )
                db.add(mod)
                db.flush()

                for fc in m_dict["flashcards"]:
                    flash = Flashcard(
                        module_id=mod.id,
                        term=fc["term"],
                        definition=fc["definition"],
                        practical_tip=fc.get("tip")
                    )
                    db.add(flash)

                for q in m_dict["quiz"]:
                    quiz_q = QuizQuestion(
                        module_id=mod.id,
                        question=q["question"],
                        options_json=json.dumps(q["options"]),
                        correct_index=q["correct_index"],
                        explanation=q["explanation"],
                        is_case_study=q.get("is_case_study", False),
                        is_exam=False
                    )
                    db.add(quiz_q)

            db.commit()

        # Seed Final Comprehensive Exam Questions (FASE 2)
        if db.query(QuizQuestion).filter(QuizQuestion.is_exam == True).count() == 0:
            exam_pool = [
                ("Berapa kalori yang dihasilkan oleh 1 gram karbohidrat?", ["2 kkal", "4 kkal", "7 kkal", "9 kkal"], 1, "Karbohidrat menghasilkan 4 kkal per gram."),
                ("Berapa kalori yang dihasilkan oleh 1 gram protein?", ["4 kkal", "6 kkal", "9 kkal", "12 kkal"], 0, "Protein menghasilkan 4 kkal per gram."),
                ("Berapa kalori yang dihasilkan oleh 1 gram lemak?", ["4 kkal", "7 kkal", "9 kkal", "12 kkal"], 2, "Lemak menghasilkan 9 kkal per gram."),
                ("Berapa proporsi sayur dan buah pada panduan Isi Piringku Kemenkes?", ["25%", "33%", "50%", "75%"], 2, "Setengah piring (50%) diisi sayur dan buah."),
                ("Rumus standar kebutuhan air harian adalah ...", ["10-15 ml/kgBB", "20-25 ml/kgBB", "30-35 ml/kgBB", "50-60 ml/kgBB"], 2, "Kebutuhan air standar adalah 30-35 ml per kg berat badan."),
                ("Prinsip 3J dalam diet diabetes singkatan dari ...", ["Jarak, Jumlah, Jamu", "Jadwal, Jumlah, Jenis", "Jenuh, Jam, Jantung", "Jantung, Jiwa, Jasmani"], 1, "3J adalah Tepat Jadwal, Tepat Jumlah, dan Tepat Jenis."),
                ("Batas asupan natrium harian yang dianjurkan Kemenkes adalah ...", ["500 mg", "1.000 mg", "2.000 mg", "4.000 mg"], 2, "Maksimal 2.000 mg natrium atau 1 sdt garam per hari."),
                ("Diet DASH dirancang khusus untuk pencegahan dan terapi ...", ["Osteoporosis", "Hipertensi", "Anemia", "Gastritis"], 1, "Diet DASH efektif menurunkan tekanan darah pada hipertensi."),
                ("Periode 1000 Hari Pertama Kehidupan (HPK) berlangsung sejak ...", ["Kelahiran sampai 3 tahun", "Konsepsi sampai anak 2 tahun", "Usia 1 sampai 5 tahun", "Pubertas"], 1, "1000 HPK adalah dari masa kehamilan (270 hari) hingga anak 2 tahun (730 hari)."),
                ("Durasi pemberian ASI Eksklusif yang direkomendasikan adalah ...", ["3 bulan", "6 bulan", "9 bulan", "12 bulan"], 1, "ASI Eksklusif diberikan selama 6 bulan pertama."),
                ("Sumber zat besi hewani (heme iron) dengan penyerapan terbaik adalah ...", ["Bayam", "Hati sapi & daging merah", "Tahu", "Tempe"], 1, "Zat besi heme dari daging dan hati diserap jauh lebih efisien daripada zat besi nabati."),
                ("Vitamin yang larut dalam lemak adalah ...", ["Vitamin B & C", "Vitamin A, D, E, K", "Vitamin B12 & Asam Folat", "Vitamin C & Zinc"], 1, "Vitamin A, D, E, dan K adalah kelompok vitamin larut lemak."),
                ("Manakah bahan makanan berindeks glikemik rendah (<55)?", ["Beras merah utuh", "Roti tawar putih", "Permen", "Sirup jagung"], 0, "Beras merah utuh memiliki serat tinggi dan indeks glikemik rendah."),
                ("Kebutuhan protein atlet latihan beban berkisar antara ...", ["0.5 - 0.8 g/kgBB", "0.8 - 1.0 g/kgBB", "1.6 - 2.2 g/kgBB", "3.0 - 4.0 g/kgBB"], 2, "1.6 - 2.2 g/kgBB optimal untuk hipertrofi dan sintesis protein otot."),
                ("Mineral utama yang membantu menurunkan tekanan darah dengan menyeimbangkan natrium adalah ...", ["Natrium", "Kalium (Potasium)", "Belerang", "Tembaga"], 1, "Kalium meningkatkan ekskresi natrium dan merelaksasi dinding arteri."),
                ("Kekurangan asupan zat gizi mikro dan protein kronis pada balita memicu kondisi ...", ["Stunting", "Hiperkolesterolemia", "Asam urat", "Katarak"], 0, "Kekurangan gizi kronis pada 1000 HPK memicu stunting (gagal tumbuh kerdil)."),
                ("Asam lemak esensial Omega-3 banyak ditemukan pada ...", ["Minyak kelapa sawit", "Ikan kembung dan salmon", "Daging sapi berlemak", "Mentega"], 1, "Ikan kembung, salmon, dan tuna kaya akan EPA dan DHA (Omega-3)."),
                ("Serat larut air bermanfaat untuk ...", ["Menaikkan gula darah", "Memperlambat penyerapan glukosa dan mengikat kolesterol", "Memicu dehidrasi", "Mengurangi penyerapan protein"], 1, "Serat larut mengontrol glukosa darah dan menurunkan kolesterol LDL."),
                ("Indeks Massa Tubuh (IMT) kategori normal untuk orang dewasa Asia adalah ...", ["< 18.5", "18.5 - 22.9", "25.0 - 29.9", "> 30.0"], 1, "Standar Kemenkes RI/WHO Asia Pasifik: 18.5 - 22.9 adalah rentang normal ideal."),
                ("Waktu terbaik untuk mengisi kembali cadangan glikogen otot setelah olahraga adalah ...", ["30 - 60 menit pasca latihan", "12 jam kemudian", "Hanya sebelum tidur", "2 hari setelahnya"], 0, "Periode awal 30-60 menit pasca latihan adalah waktu emas resintesis glikogen otot.")
            ]

            for q_text, opts, ans_idx, expl in exam_pool:
                eq = QuizQuestion(
                    module_id=None,
                    question=q_text,
                    options_json=json.dumps(opts),
                    correct_index=ans_idx,
                    explanation=expl,
                    is_case_study=False,
                    is_exam=True
                )
                db.add(eq)
            db.commit()

    except Exception as e:
        db.rollback()
        raise e
    finally:
        db.close()

