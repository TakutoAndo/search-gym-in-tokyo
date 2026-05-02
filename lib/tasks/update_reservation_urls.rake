namespace :gym do
  # 各区のスポーツ施設予約システムURL
  WARD_RESERVATION_URLS = {
    "中央区"   => "https://chuo-yoyaku.openreaf02.jp/",
    "文京区"   => "https://www.shisetsu.city.bunkyo.lg.jp/user/Home",
    "台東区"   => "https://shisetsu.city.taito.lg.jp/",
    "墨田区"   => "https://yoyaku03.city.sumida.lg.jp/user/Home",
    "江東区"   => "https://yoyaku.koto-sports.net/koto_v2/reserve/gin_menu",
    "品川区"   => "https://yoyaku.city.shinagawa.tokyo.jp/",
    "目黒区"   => "https://resv.city.meguro.tokyo.jp/Web/Home/WgR_ModeSelect",
    "大田区"   => "https://www.yoyaku.city.ota.tokyo.jp/",
    "世田谷区" => "https://setagaya.keyakinet.net/Web/",
    "渋谷区"   => "https://www.yoyaku.city.shibuya.tokyo.jp/",
    "中野区"   => "https://yoyaku.nakano-tokyo.jp/stagia/reserve/gsm_init",
    "杉並区"   => "https://www.yoyaku.city.suginami.tokyo.jp/",
    "豊島区"   => "https://www2.pf489.com/Toshima/webR/",
    "荒川区"   => "https://shisetsu.city.arakawa.tokyo.jp/stagia/reserve/gin_menu",
    "板橋区"   => "https://www.city.itabashi.tokyo.jp/kusei/joho/yoyaku/1010244.html",
    "練馬区"   => "https://yoyaku.city.nerima.tokyo.jp/stagia/reserve/gin_menu",
    "足立区"   => "https://yoyakusystem.city.adachi.tokyo.jp/web/",
    "葛飾区"   => "https://rsv.shisetsu.city.katsushika.lg.jp/katsushika/web/menu.jsp",
    "江戸川区" => "https://www.shisetsuyoyaku.city.edogawa.tokyo.jp/user/Home"
  }.freeze

  desc "各区の施設予約システムURLをgymsテーブルのreservation_urlに一括登録"
  task update_reservation_urls: :environment do
    updated = 0

    WARD_RESERVATION_URLS.each do |ward, url|
      count = Gym.where(ward: ward).update_all(reservation_url: url)
      puts "#{ward}: #{count}件更新"
      updated += count
    end

    puts "\n完了: 合計#{updated}件更新"
  end
end
