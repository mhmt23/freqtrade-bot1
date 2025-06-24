# Freqtrade Bot - Otomatik Crypto Trading

Bu repository, Binance Testnet üzerinde çalışan otomatik kripto para trading botu içerir.

## Özellikler

- ✅ Binance Testnet entegrasyonu
- ✅ Scalping stratejisi
- ✅ Otomatik kurulum scripti
- ✅ Web monitoring dashboard
- ✅ Cron job ile otomatik restart
- ✅ Detaylı loglama

## Hızlı Kurulum

```bash
# Ana dizine git
cd /home/dcoakelc/

# Kurulum scriptini indir ve çalıştır
wget https://raw.githubusercontent.com/mhmt23/freqtrade-bot1/main/clean_install.sh
chmod +x clean_install.sh
./clean_install.sh
```

## Manuel Kurulum

1. Repository'yi klonlayın:
```bash
git clone https://github.com/mhmt23/freqtrade-bot1.git
cd freqtrade-bot1
```

2. Python paketlerini yükleyin:
```bash
pip3 install freqtrade[plot] --user
pip3 install ccxt pandas numpy requests --user
pip3 install ft-pandas-ta --user
```

3. Bot'u başlatın:
```bash
nohup python3 -m freqtrade trade --config config.json --strategy SimpleScalpingStrategy > bot.log 2>&1 &
```

## Dosya Yapısı

```
freqtrade-bot1/
├── clean_install.sh          # Otomatik kurulum scripti
├── config.json               # Bot konfigürasyonu
├── requirements.txt          # Python bağımlılıkları
├── user_data/
│   └── strategies/
│       └── SimpleScalpingStrategy.py  # Trading stratejisi
├── restart_bot.sh            # Bot restart scripti
├── bot.log                   # Bot logları
└── bot.pid                   # Bot process ID
```

## Web Dashboard

Bot çalıştıktan sonra web dashboard'a şu adresten erişebilirsiniz:
- **Ana Dashboard:** http://akelclinics.com/freqtrade-bot/
- **Detaylı Status:** http://akelclinics.com/freqtrade-bot/status.php

## Konfigürasyon

### Binance Testnet API
Bot Binance Testnet kullanır. API key'ler config.json dosyasında tanımlıdır.

### Trading Çiftleri
- BTC/USDT
- ETH/USDT
- BNB/USDT
- ADA/USDT
- DOT/USDT

### Risk Yönetimi
- **Max Open Trades:** 3
- **Stake Amount:** 50 USDT
- **Stoploss:** %5
- **ROI:** %1-3

## Monitoring

### Log Dosyaları
- `/home/dcoakelc/freqtrade_install.log` - Kurulum logları
- `/home/dcoakelc/freqtrade-bot1/bot.log` - Bot logları
- `/home/dcoakelc/freqtrade-bot1/bot_restart.log` - Restart logları

### Bot Durumu Kontrolü
```bash
# Bot çalışıyor mu?
ps aux | grep freqtrade

# Log dosyalarını kontrol et
tail -f /home/dcoakelc/freqtrade-bot1/bot.log

# Kurulum loglarını kontrol et
cat /home/dcoakelc/freqtrade_install.log
```

## Sorun Giderme

### Bot başlamıyor
1. Log dosyalarını kontrol edin
2. Python paketlerinin yüklü olduğundan emin olun
3. API key'lerin doğru olduğunu kontrol edin

### Web dashboard açılmıyor
1. Web dizininin oluşturulduğunu kontrol edin: `/home/dcoakelc/public_html/freqtrade-bot/`
2. Dosya izinlerini kontrol edin

### Cron job çalışmıyor
```bash
# Cron job'ları listele
crontab -l

# Cron log'larını kontrol et
tail -f /var/log/cron
```

## Güvenlik Uyarısı

⚠️ **Bu bot test amaçlıdır ve Binance Testnet kullanır.**
⚠️ **Gerçek para ile trading yapmadan önce stratejinizi test edin.**
⚠️ **Risk yönetimi kurallarınızı mutlaka uygulayın.**

## Lisans

MIT License

## Destek

Issues veya sorularınız için GitHub Issues kullanın.
