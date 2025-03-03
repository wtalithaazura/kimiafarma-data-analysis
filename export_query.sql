-- Membuat tabel baru "kf_tabel_analisis" berdasarkan hasil agregasi dari beberapa tabel
CREATE TABLE `kimia_farma.kf_tabel_analisis` AS
SELECT 
  -- Mengambil ID transaksi dan tanggal transaksi dari tabel transaksi akhir
  ft.transaction_id,
  ft.date,

  -- Mengambil ID cabang dan informasi cabang dari tabel kantor cabang
  ft.branch_id,
  kc.branch_name,  -- Nama cabang
  kc.kota,         -- Kota cabang
  kc.provinsi,     -- Provinsi cabang
  CAST(kc.rating AS FLOAT64) AS rating_cabang, -- Konversi rating cabang ke FLOAT64

  -- Mengambil informasi pelanggan dari tabel transaksi
  ft.customer_name,

  -- Mengambil ID produk dan informasi produk dari tabel produk
  ft.product_id,
  p.product_name, -- Nama produk / obat
  p.price AS actual_price, -- Harga asli sebelum diskon

  -- Mengambil persentase diskon dari tabel transaksi dan mengonversinya ke FLOAT64
  CAST(ft.discount_percentage AS FLOAT64) AS discount_percentage,

  -- Menghitung persentase laba berdasarkan harga produk
  CASE 
    WHEN p.price <= 50000 THEN 0.10  -- Jika harga <= 50.000, laba 10%
    WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15  -- Harga > 50.000 - 100.000, laba 15%
    WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20 -- Harga > 100.000 - 300.000, laba 20%
    WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25 -- Harga > 300.000 - 500.000, laba 25%
    ELSE 0.30  -- Harga > 500.000, laba 30%
  END AS persentase_gross_laba,

  -- Menghitung harga setelah diskon
  CAST((p.price - (p.price * ft.discount_percentage / 100)) AS FLOAT64) AS nett_sales,

  -- Menghitung keuntungan bersih setelah diskon
  CAST(((p.price - (p.price * ft.discount_percentage / 100)) * 
    CASE 
      WHEN p.price <= 50000 THEN 0.10
      WHEN p.price > 50000 AND p.price <= 100000 THEN 0.15
      WHEN p.price > 100000 AND p.price <= 300000 THEN 0.20
      WHEN p.price > 300000 AND p.price <= 500000 THEN 0.25
      ELSE 0.30
    END
  ) AS FLOAT64) AS nett_profit,

  -- Mengambil rating transaksi dari tabel transaksi dan mengonversinya ke FLOAT64
  CAST(ft.rating AS FLOAT64) AS rating_transaksi  

-- Mengambil data dari tabel transaksi akhir sebagai tabel utama
FROM `kimia_farma.kf_final_transaction` ft  

-- Menggabungkan tabel kantor cabang berdasarkan branch_id
LEFT JOIN `kimia_farma.kf_kantor_cabang` kc  
  ON ft.branch_id = kc.branch_id

-- Menggabungkan tabel produk berdasarkan product_id
LEFT JOIN `kimia_farma.kf_product` p  
  ON ft.product_id = p.product_id;
