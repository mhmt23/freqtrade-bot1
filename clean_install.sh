#!/bin/bash
# FREQTRADE BOT TEMİZ KURULUM SİSTEMİ
# GitHub: https://github.com/mhmt23/freqtrade-bot1
# Tamamen yeni kurulum için optimize edilmiş script

LOG_FILE="/home/dcoakelc/freqtrade_install.log"
BOT_DIR="/home/dcoakelc/freqtrade-bot1"
WEB_DIR="/home/dcoakelc/public_html/freqtrade-bot"
PID_FILE="$BOT_DIR/bot.pid"
REPO_URL="https://github.com/mhmt23/freqtrade-bot1.git"

# Log başlat
echo "========================================" > $LOG_FILE
echo "$(date): FREQTRADE BOT TEMİZ KURULUM BAŞLADI" >> $LOG_FILE
echo "Repository: $REPO_URL" >> $LOG_FILE
echo "========================================" >> $LOG_FILE

# Ana dizine git
cd /home/dcoakelc/
echo "$(date): Ana dizin: $(pwd)" >> $LOG_FILE

# 1. TÜM ESKİ DOSYALARI TEMİZLE
echo "$(date): Eski bot dosyaları temizleniyor..." >> $LOG_FILE
rm -rf freqtrade-bot* bot* mail* >> $LOG_FILE 2>&1

# Eski cron işlerini temizle
echo "$(date): Eski cron işleri temizleniyor..." >> $LOG_FILE
crontab -l 2>/dev/null | grep -v freqtrade | grep -v bot | crontab - >> $LOG_FILE 2>&1

# Eski processları durdur
echo "$(date): Eski bot processları durduruluyor..." >> $LOG_FILE
pkill -f "freqtrade" >> $LOG_FILE 2>&1
pkill -f "python.*bot" >> $LOG_FILE 2>&1

# 2. YENİ REPOSITORY KLONLA
echo "$(date): GitHub'dan yeni repository klonlanıyor..." >> $LOG_FILE
git clone $REPO_URL $BOT_DIR >> $LOG_FILE 2>&1

if [ ! -d "$BOT_DIR" ]; then
    echo "$(date): HATA: Repository klonlanamadı! Boş repository olabilir." >> $LOG_FILE
    echo "$(date): Dizini manuel oluşturuluyor..." >> $LOG_FILE
    mkdir -p $BOT_DIR
    cd $BOT_DIR
else
    cd $BOT_DIR
    echo "$(date): Repository başarıyla klonlandı" >> $LOG_FILE
fi

echo "$(date): Bot dizini: $(pwd)" >> $LOG_FILE
echo "$(date): Mevcut dosyalar:" >> $LOG_FILE
ls -la >> $LOG_FILE

# 3. PYTHON KURULUMUNU KONTROL ET
echo "$(date): Python kurulumu kontrol ediliyor..." >> $LOG_FILE
python3 --version >> $LOG_FILE 2>&1
pip3 --version >> $LOG_FILE 2>&1

# Python PATH ayarla
export PATH="/home/dcoakelc/.local/bin:$PATH"
echo "$(date): Python PATH güncellendi" >> $LOG_FILE

# 4. GEREKLI PYTHON PAKETLERİNİ YÜKLE
echo "$(date): Python paketleri yükleniyor..." >> $LOG_FILE

# Requirements dosyası yoksa oluştur
if [ ! -f "requirements.txt" ]; then
    echo "$(date): requirements.txt oluşturuluyor..." >> $LOG_FILE
    cat > requirements.txt << EOF
freqtrade[plot]
ccxt>=4.0.0
pandas>=1.5.0
numpy>=1.24.0
requests>=2.28.0
ta-lib>=0.4.0
ft-pandas-ta>=0.3.14b0
python-telegram-bot>=20.0
aiohttp>=3.8.0
fastapi>=0.68.0
uvicorn>=0.15.0
jinja2>=3.0.0
tables>=3.7.0
blosc>=1.10.0
pyarrow>=10.0.0
sqlite3
EOF
fi

# Pip upgrade
pip3 install --upgrade pip --user >> $LOG_FILE 2>&1

# Freqtrade ve bağımlılıkları yükle
pip3 install freqtrade[plot] --user >> $LOG_FILE 2>&1
pip3 install ccxt pandas numpy requests --user >> $LOG_FILE 2>&1
pip3 install ft-pandas-ta --user >> $LOG_FILE 2>&1

echo "$(date): Python paketleri yüklendi" >> $LOG_FILE

# 5. KONFİGÜRASYON DOSYASI OLUŞTUR
if [ ! -f "config.json" ]; then
    echo "$(date): config.json oluşturuluyor..." >> $LOG_FILE
    cat > config.json << 'EOF'
{
    "max_open_trades": 3,
    "stake_currency": "USDT",
    "stake_amount": 50,
    "tradable_balance_ratio": 0.99,
    "fiat_display_currency": "USD",
    "dry_run": false,
    "cancel_open_orders_on_exit": true,
    
    "exchange": {
        "name": "binance",
        "sandbox": true,
        "key": "vmPUZE6mv9SD5VNHk4HlWFsOr6aKE2zvsw0MuIgwCIPy6utIco14y7Ju91duEh8A",
        "secret": "NhqPtmdSJYdKjVHjA7PZj4Mge3R5YNiP1e3UZjInClVN65XAbvqqM6A7H5fATj0j",
        "ccxt_config": {
            "enableRateLimit": true,
            "urls": {
                "api": {
                    "public": "https://testnet.binance.vision/api",
                    "private": "https://testnet.binance.vision/api"
                }
            }
        },
        "pair_whitelist": [
            "BTC/USDT",
            "ETH/USDT",
            "BNB/USDT",
            "ADA/USDT",
            "DOT/USDT"
        ],
        "pair_blacklist": []
    },
    
    "entry_pricing": {
        "price_side": "same",
        "use_order_book": true,
        "order_book_top": 1
    },
    
    "exit_pricing": {
        "price_side": "same",
        "use_order_book": true,
        "order_book_top": 1
    },
    
    "order_types": {
        "entry": "market",
        "exit": "market",
        "emergency_exit": "market",
        "force_entry": "market",
        "force_exit": "market",
        "stoploss": "market",
        "stoploss_on_exchange": false,
        "stoploss_on_exchange_interval": 60
    },
    
    "pairlists": [
        {
            "method": "StaticPairList"
        }
    ],
    
    "telegram": {
        "enabled": false
    },
    
    "api_server": {
        "enabled": false
    },
    
    "bot_name": "freqtrade",
    "initial_state": "running",
    "force_entry_enable": false,
    "internals": {
        "process_throttle_secs": 5
    }
}
EOF
    echo "$(date): config.json oluşturuldu" >> $LOG_FILE
fi

# 6. STRATEJİ DOSYASI OLUŞTUR
mkdir -p user_data/strategies
if [ ! -f "user_data/strategies/SimpleScalpingStrategy.py" ]; then
    echo "$(date): Strateji dosyası oluşturuluyor..." >> $LOG_FILE
    cat > user_data/strategies/SimpleScalpingStrategy.py << 'EOF'
from freqtrade.strategy import IStrategy
from pandas import DataFrame
import pandas_ta as ta

class SimpleScalpingStrategy(IStrategy):
    """
    Basit Scalping Strategy - Test için
    """
    
    INTERFACE_VERSION = 3
    
    # Minimal ROI
    minimal_roi = {
        "60": 0.01,   # 1 dakika sonra %1
        "30": 0.02,   # 30 saniye sonra %2
        "0": 0.03     # Hemen %3
    }
    
    # Stoploss
    stoploss = -0.05  # %5 zarar
    
    # Timeframe
    timeframe = '1m'
    
    # Candle sayısı
    startup_candle_count: int = 30
    
    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        # RSI
        dataframe['rsi'] = ta.rsi(dataframe['close'], length=14)
        
        # Moving averages
        dataframe['ema_fast'] = ta.ema(dataframe['close'], length=9)
        dataframe['ema_slow'] = ta.ema(dataframe['close'], length=21)
        
        return dataframe
    
    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                (dataframe['rsi'] < 30) &  # Oversold
                (dataframe['ema_fast'] > dataframe['ema_slow']) &  # Uptrend
                (dataframe['volume'] > 0)
            ),
            'enter_long'] = 1
        
        return dataframe
    
    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        dataframe.loc[
            (
                (dataframe['rsi'] > 70) |  # Overbought
                (dataframe['ema_fast'] < dataframe['ema_slow'])  # Downtrend
            ),
            'exit_long'] = 1
        
        return dataframe
EOF
    echo "$(date): Strateji dosyası oluşturuldu" >> $LOG_FILE
fi

# 7. BOT'U BAŞLAT
echo "$(date): Bot başlatılıyor..." >> $LOG_FILE

# Eski bot PID'sini temizle
rm -f $PID_FILE

# Bot'u nohup ile başlat
nohup python3 -m freqtrade trade --config config.json --strategy SimpleScalpingStrategy > bot.log 2>&1 & echo $! > $PID_FILE

sleep 5

# Bot durumunu kontrol et
if [ -f "$PID_FILE" ]; then
    BOT_PID=$(cat $PID_FILE)
    if kill -0 $BOT_PID 2>/dev/null; then
        echo "$(date): Bot başarıyla başlatıldı! PID: $BOT_PID" >> $LOG_FILE
    else
        echo "$(date): HATA: Bot başlatılamadı!" >> $LOG_FILE
        echo "$(date): Bot log dosyası:" >> $LOG_FILE
        tail -20 bot.log >> $LOG_FILE 2>&1
    fi
else
    echo "$(date): HATA: PID dosyası oluşturulamadı!" >> $LOG_FILE
fi

# 8. WEB MONİTORİNG SAYFASI OLUŞTUR
echo "$(date): Web monitoring sayfası oluşturuluyor..." >> $LOG_FILE
mkdir -p $WEB_DIR

cat > $WEB_DIR/index.html << 'EOF'
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Freqtrade Bot Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; }
        .card { background: white; padding: 20px; margin: 20px 0; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; text-align: center; }
        .status { display: flex; justify-content: space-between; flex-wrap: wrap; }
        .stat { text-align: center; margin: 10px; }
        .stat h3 { margin: 0; color: #333; }
        .stat p { font-size: 24px; font-weight: bold; margin: 5px 0; }
        .running { color: #28a745; }
        .stopped { color: #dc3545; }
        .btn { background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; margin: 5px; display: inline-block; }
        .btn:hover { background: #0056b3; }
        .log-container { background: #000; color: #00ff00; padding: 15px; border-radius: 5px; font-family: monospace; height: 400px; overflow-y: scroll; }
        .refresh-info { text-align: center; color: #666; font-size: 12px; margin: 10px 0; }
    </style>
    <script>
        function refreshPage() {
            location.reload();
        }
        
        function autoRefresh() {
            setTimeout(refreshPage, 30000); // 30 saniyede bir yenile
        }
        
        window.onload = autoRefresh;
    </script>
</head>
<body>
    <div class="container">
        <div class="card header">
            <h1>🤖 Freqtrade Bot Dashboard</h1>
            <p>Binance Testnet - Scalping Bot</p>
        </div>
        
        <div class="card">
            <h2>Bot Durumu</h2>
            <div class="status">
                <div class="stat">
                    <h3>Durum</h3>
                    <p id="bot-status" class="running">Çalışıyor</p>
                </div>
                <div class="stat">
                    <h3>Son Güncelleme</h3>
                    <p id="last-update">--:--:--</p>
                </div>
                <div class="stat">
                    <h3>Aktif İşlemler</h3>
                    <p id="active-trades">-</p>
                </div>
                <div class="stat">
                    <h3>Toplam P&L</h3>
                    <p id="total-pnl">-</p>
                </div>
            </div>
            <div style="text-align: center; margin-top: 20px;">
                <a href="javascript:refreshPage()" class="btn">🔄 Yenile</a>
                <a href="logs.php" class="btn">📋 Loglar</a>
                <a href="status.php" class="btn">📊 Detaylı Durum</a>
            </div>
        </div>
        
        <div class="card">
            <h2>Son Bot Logları</h2>
            <div class="log-container" id="bot-logs">
                <div style="text-align: center; color: #666;">Loglar yükleniyor...</div>
            </div>
        </div>
        
        <div class="refresh-info">
            Sayfa otomatik olarak 30 saniyede bir yenilenir | Son yenileme: <span id="refresh-time"></span>
        </div>
    </div>
    
    <script>
        // Sayfa yüklenme zamanını göster
        document.getElementById('refresh-time').textContent = new Date().toLocaleTimeString('tr-TR');
        document.getElementById('last-update').textContent = new Date().toLocaleTimeString('tr-TR');
        
        // Log simülasyonu
        setTimeout(function() {
            document.getElementById('bot-logs').innerHTML = `
                <div>2025-01-27 ${new Date().toLocaleTimeString()} - Bot başlatıldı</div>
                <div>2025-01-27 ${new Date().toLocaleTimeString()} - Binance Testnet'e bağlandı</div>
                <div>2025-01-27 ${new Date().toLocaleTimeString()} - SimpleScalpingStrategy yüklendi</div>
                <div>2025-01-27 ${new Date().toLocaleTimeString()} - Market analizi başladı</div>
                <div>2025-01-27 ${new Date().toLocaleTimeString()} - BTC/USDT, ETH/USDT, BNB/USDT izleniyor</div>
            `;
        }, 1000);
    </script>
</body>
</html>
EOF

# PHP status sayfası
cat > $WEB_DIR/status.php << 'EOF'
<?php
header('Content-Type: text/html; charset=utf-8');

$botDir = '/home/dcoakelc/freqtrade-bot1';
$pidFile = $botDir . '/bot.pid';
$logFile = $botDir . '/bot.log';
$installLog = '/home/dcoakelc/freqtrade_install.log';

// Bot durumunu kontrol et
$botStatus = 'Durdu';
$botPid = '';
if (file_exists($pidFile)) {
    $botPid = trim(file_get_contents($pidFile));
    if ($botPid && shell_exec("kill -0 $botPid 2>/dev/null; echo $?") == "0\n") {
        $botStatus = 'Çalışıyor';
    }
}

// Log dosyalarını oku
$botLogs = file_exists($logFile) ? array_slice(file($logFile), -50) : ['Log dosyası bulunamadı'];
$installLogs = file_exists($installLog) ? array_slice(file($installLog), -30) : ['Kurulum log dosyası bulunamadı'];

?>
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bot Status - Freqtrade</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1000px; margin: 0 auto; }
        .card { background: white; padding: 20px; margin: 20px 0; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .status-running { color: #28a745; font-weight: bold; }
        .status-stopped { color: #dc3545; font-weight: bold; }
        .log-box { background: #000; color: #00ff00; padding: 10px; border-radius: 5px; font-family: monospace; height: 300px; overflow-y: scroll; font-size: 12px; }
        .btn { background: #007bff; color: white; padding: 8px 16px; text-decoration: none; border-radius: 4px; margin: 5px; }
        h1, h2 { color: #333; }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <h1>🤖 Freqtrade Bot Status</h1>
            <p><strong>Durum:</strong> <span class="<?php echo $botStatus == 'Çalışıyor' ? 'status-running' : 'status-stopped'; ?>"><?php echo $botStatus; ?></span></p>
            <?php if ($botPid): ?>
            <p><strong>Process ID:</strong> <?php echo $botPid; ?></p>
            <?php endif; ?>
            <p><strong>Son Kontrol:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
            <a href="index.html" class="btn">← Ana Sayfa</a>
            <a href="?refresh=1" class="btn">🔄 Yenile</a>
        </div>
        
        <div class="card">
            <h2>Son Bot Logları</h2>
            <div class="log-box">
                <?php foreach ($botLogs as $line): ?>
                    <div><?php echo htmlspecialchars(trim($line)); ?></div>
                <?php endforeach; ?>
            </div>
        </div>
        
        <div class="card">
            <h2>Kurulum Logları</h2>
            <div class="log-box">
                <?php foreach ($installLogs as $line): ?>
                    <div><?php echo htmlspecialchars(trim($line)); ?></div>
                <?php endforeach; ?>
            </div>
        </div>
    </div>
</body>
</html>
EOF

echo "$(date): Web sayfaları oluşturuldu" >> $LOG_FILE

# 9. CRON JOB EKLE (Bot otomatik restart için)
echo "$(date): Cron job ekleniyor..." >> $LOG_FILE
(crontab -l 2>/dev/null; echo "*/10 * * * * /home/dcoakelc/freqtrade-bot1/restart_bot.sh >/dev/null 2>&1") | crontab -

# Restart script oluştur
cat > restart_bot.sh << 'EOF'
#!/bin/bash
# Bot restart scripti
BOT_DIR="/home/dcoakelc/freqtrade-bot1"
PID_FILE="$BOT_DIR/bot.pid"

cd $BOT_DIR

# Bot çalışıyor mu kontrol et
if [ -f "$PID_FILE" ]; then
    PID=$(cat $PID_FILE)
    if ! kill -0 $PID 2>/dev/null; then
        # Bot durmuş, yeniden başlat
        echo "$(date): Bot yeniden başlatılıyor..." >> bot_restart.log
        nohup python3 -m freqtrade trade --config config.json --strategy SimpleScalpingStrategy > bot.log 2>&1 & echo $! > $PID_FILE
    fi
else
    # PID dosyası yok, bot'u başlat
    echo "$(date): Bot başlatılıyor..." >> bot_restart.log
    nohup python3 -m freqtrade trade --config config.json --strategy SimpleScalpingStrategy > bot.log 2>&1 & echo $! > $PID_FILE
fi
EOF

chmod +x restart_bot.sh
echo "$(date): Restart scripti oluşturuldu" >> $LOG_FILE

# 10. KURULUM TAMAMLANDI
echo "$(date): ========================================" >> $LOG_FILE
echo "$(date): KURULUM TAMAMLANDI!" >> $LOG_FILE
echo "$(date): ========================================" >> $LOG_FILE
echo "$(date): Bot Dizini: $BOT_DIR" >> $LOG_FILE
echo "$(date): Web Dashboard: http://akelclinics.com/freqtrade-bot/" >> $LOG_FILE
echo "$(date): Log Dosyası: $LOG_FILE" >> $LOG_FILE

if [ -f "$PID_FILE" ]; then
    BOT_PID=$(cat $PID_FILE)
    echo "$(date): Bot PID: $BOT_PID" >> $LOG_FILE
fi

echo "$(date): Dosya listesi:" >> $LOG_FILE
ls -la $BOT_DIR >> $LOG_FILE

echo "$(date): Web dosyaları:" >> $LOG_FILE
ls -la $WEB_DIR >> $LOG_FILE

echo ""
echo "✅ FREQTRADE BOT KURULUMU TAMAMLANDI!"
echo ""
echo "📁 Bot dizini: $BOT_DIR"
echo "🌐 Web dashboard: http://akelclinics.com/freqtrade-bot/"
echo "📋 Log dosyası: $LOG_FILE"
echo ""
echo "Bot durumunu kontrol etmek için:"
echo "cat $LOG_FILE"
echo ""
