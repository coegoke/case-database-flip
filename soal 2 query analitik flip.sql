-- 1. pada tahun berapa nominal transfer berhasil terbanyak?
SELECT EXTRACT(YEAR FROM created_at) tahun,
		COUNT(transaksi_id) Jumlah_transaksi,
		SUM(amount) Jumlah_nominal
FROM transaksi
where status = 'berhasil'
GROUP BY tahun
ORDER BY tahun asc;

-- 2. siapa top 5 pengguna beserta email dan nomor telepon 
-- dengan rate transaksi berhasil,gagal,dan dibatalkan
SELECT p.username,
		p.nomor_hp,
		p.email,
		ROUND((COUNT(CASE WHEN t.status = 'berhasil' THEN 1 END) * 100.0) / 
		total_transaksi,4) AS Persentase_berhasil,
		ROUND((COUNT(CASE WHEN t.status = 'gagal' THEN 1 END) * 100.0) / 
		total_transaksi,4) AS Persentase_gagal,
		ROUND((COUNT(CASE WHEN t.status = 'dibatalkan' THEN 1 END) * 100.0) / 
		total_transaksi,4) AS Persentase_dibatalkan
FROM transaksi t
JOIN pengguna p ON p.user_id = t.user_id
CROSS JOIN (SELECT COUNT(*) AS total_transaksi FROM transaksi) AS total
GROUP BY p.username, p.nomor_hp, p.email, total.total_transaksi
ORDER BY Persentase_berhasil DESC
LIMIT 5;

-- 3. pada quartal tahun berapa dengan user baru terbanyak?
SELECT CONCAT(EXTRACT(YEAR FROM created_at),' Q', 
			  EXTRACT(quarter FROM created_at)) quartal_tahun,
		COUNT(*) Jumlah_User	
FROM pengguna
GROUP BY quartal_tahun
ORDER BY quartal_tahun ASC;

-- 4. jenis metode transfer dengan transaksi berhasil nominal terbanyak
SELECT DISTINCT metode_transfer,
		COUNT(metode_transfer) total_transaksi,
		sum(amount) total_nominal
from transfer_pengirim tp
	join transfer t on tp.transfer_pengirim_id=t.transfer_pengirim_id
	join transaksi tr on t.transfer_id=tr.transfer_id
where status = 'berhasil'
GROUP BY metode_transfer;

-- 5. bank dengan 5 transaksi berhasil nominal terbanyak
SELECT nama_bank, 
	COUNT(*) AS total_transaksi, 
	SUM(amount) AS total_nominal
FROM bank
	JOIN transfer_pengirim ON bank.bank_id = transfer_pengirim.bank_id
	JOIN transfer ON transfer_pengirim.transfer_pengirim_id = transfer.transfer_pengirim_id
	JOIN transaksi ON transfer.transfer_id = transaksi.transfer_id
where status = 'berhasil'
GROUP BY nama_bank
ORDER BY total_nominal DESC
LIMIT 5;

-- 6. keperluan transfer dengan transaksi berhasil nominal terbanyak
SELECT keperluan_transfer,
		COUNT(keperluan_transfer) total_transaksi,
		sum(amount) total_nominal
from transfer_penerima tp
	join transfer t on tp.transfer_penerima_id=t.transfer_penerima_id
	join transaksi tr on t.transfer_id=tr.transfer_id
where status = 'berhasil'
GROUP BY keperluan_transfer
ORDER BY total_transaksi DESC;

-- 7. persentase transaksi berdasarkan status transaksi
SELECT status, 
COUNT(*) * 100.0 / (SELECT COUNT(*) FROM transaksi) AS persentase
FROM transaksi
GROUP BY status;
