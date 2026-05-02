require "csv"
require "open-uri"
require "net/http"
require "json"

namespace :gym do
  WARD_CSV_URLS = {
    "中央区"   => "https://www.opendata.metro.tokyo.lg.jp/chuo/131024_chuoku_sportsfacilities.csv",
    "文京区"   => "https://www.opendata.metro.tokyo.lg.jp/bunkyo/131059_bunkyoku_sportsfacilities.csv",
    "台東区"   => "https://www.opendata.metro.tokyo.lg.jp/taito/131067_taitoku_sportsfacilities.csv",
    "墨田区"   => "https://www.opendata.metro.tokyo.lg.jp/sumida/131075_sumidaku_sportsfacilities.csv",
    "江東区"   => "https://www.opendata.metro.tokyo.lg.jp/koto/131083_kotoku_sportsfacilities.csv",
    "品川区"   => "https://www.opendata.metro.tokyo.lg.jp/shinagawa/131091_shinagawaku_sportsfacilities.csv",
    "目黒区"   => "https://www.opendata.metro.tokyo.lg.jp/meguro/131105_meguroku_sportsfacilities.csv",
    "大田区"   => "https://www.opendata.metro.tokyo.lg.jp/ota/131113_otaku_sportsfacilities.csv",
    "世田谷区" => "https://www.opendata.metro.tokyo.lg.jp/setagaya/131121_setagayaku_sportsfacilities.csv",
    "渋谷区"   => "https://www.opendata.metro.tokyo.lg.jp/shibuya/131130_shibuyaku_sportsfacilities.csv",
    "中野区"   => "https://www.opendata.metro.tokyo.lg.jp/nakano/131148_nakanoku_sportsfacilities.csv",
    "杉並区"   => "https://www.opendata.metro.tokyo.lg.jp/suginami/131156_suginamiku_sportsfacilities.csv",
    "豊島区"   => "https://www.opendata.metro.tokyo.lg.jp/toshima/131164_toshimaku_sportsfacilities.csv",
    "荒川区"   => "https://www.opendata.metro.tokyo.lg.jp/arakawa/131181_arakawaku_sportsfacilities.csv",
    "板橋区"   => "https://www.opendata.metro.tokyo.lg.jp/itabashi/131199_itabashiku_sportsfacilities.csv",
    "練馬区"   => "https://www.opendata.metro.tokyo.lg.jp/nerima/131202_nerimaku_sportsfacilities.csv",
    "足立区"   => "https://www.opendata.metro.tokyo.lg.jp/adachi/131211_adachiku_sportsfacilities.csv",
    "葛飾区"   => "https://www.opendata.metro.tokyo.lg.jp/katsushika/131229_katsushikaku_sportsfacilities.csv",
    "江戸川区" => "https://www.opendata.metro.tokyo.lg.jp/edogawa/131237_edogawaku_sportsfacilities.csv"
  }.freeze

  # HeartRails Express API: 緯度経度から最寄り駅名を取得
  # 利用: HeartRails Express (https://express.heartrails.com/)
  # 出典: 「位置参照情報ダウンロードサービス」（国土交通省）を加工して作成
  def fetch_nearest_station(latitude, longitude)
    return nil if latitude.blank? || longitude.blank?

    uri = URI("https://express.heartrails.com/api/json")
    uri.query = URI.encode_www_form(method: "getStations", x: longitude, y: latitude)
    response = Net::HTTP.get_response(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    data.dig("response", "station", 0, "name")
  rescue => e
    puts "    [HeartRails APIエラー] #{e.message}"
    nil
  end

  # HeartRails GeoAPI: 郵便番号から座標を取得し、最寄り駅名を返す
  def fetch_nearest_station_by_postal(postal_code)
    return nil if postal_code.blank?

    # 郵便番号 → 座標
    geo_uri = URI("https://geoapi.heartrails.com/api/json")
    geo_uri.query = URI.encode_www_form(method: "searchByPostal", postal: postal_code)
    geo_response = Net::HTTP.get_response(geo_uri)
    return nil unless geo_response.is_a?(Net::HTTPSuccess)

    geo_data = JSON.parse(geo_response.body)
    location = geo_data.dig("response", "location", 0)
    return nil unless location

    # 座標 → 最寄り駅
    sleep(0.2)
    fetch_nearest_station(location["y"], location["x"])
  rescue => e
    puts "    [HeartRails GeoAPIエラー] #{e.message}"
    nil
  end

  desc "東京都オープンデータからバドミントン利用可能な施設をインポートし、最寄り駅を補完する"
  task import_from_open_data: :environment do
    imported = 0
    updated  = 0
    skipped  = 0

    WARD_CSV_URLS.each do |ward, url|
      puts "\n#{ward} を処理中..."

      begin
        raw = URI.open(url).read.force_encoding("UTF-8").encode("UTF-8", invalid: :replace, undef: :replace)
        raw.gsub!(/\A﻿/, "")

        CSV.parse(raw, headers: true) do |row|
          next unless row["バドミントン"] == "有"

          name = row["名称"].presence
          next if name.blank?

          gym = Gym.find_or_initialize_by(name: name, ward: ward)
          is_new = gym.new_record?

          gym.assign_attributes(
            address:     row["所在地_連結表記"].presence,
            postal_code: row["郵便番号"].presence,
            phone:       row["電話番号"].presence&.gsub(/[（）]/, "（" => "(", "）" => ")"),
            website:     row["URL"].presence,
            notes:       row["備考"].presence
          )

          # 最寄り駅が未登録の場合のみAPIを呼ぶ
          if gym.nearest_station.blank?
            lat = row["緯度"].presence
            lng = row["経度"].presence
            postal = row["郵便番号"].presence

            station = if lat.present? && lng.present?
              fetch_nearest_station(lat, lng)
            elsif postal.present?
              fetch_nearest_station_by_postal(postal)
            end

            if station
              gym.nearest_station = station
              print "    → 最寄り駅: #{station}"
              sleep(0.3)
            end
          end

          if gym.save
            puts is_new ? "  追加 #{gym.name}" : "  更新 #{gym.name}"
            is_new ? imported += 1 : updated += 1
          else
            skipped += 1
            puts "  スキップ #{name}: #{gym.errors.full_messages.join(", ")}"
          end
        end

      rescue OpenURI::HTTPError => e
        puts "  HTTPエラー（CSVなし）: #{e.message}"
      rescue => e
        puts "  エラー: #{e.message}"
      end
    end

    puts "\n============================="
    puts "完了: 追加 #{imported}件 / 更新 #{updated}件 / スキップ #{skipped}件"
    puts "合計施設数: #{Gym.count}件"
  end

  desc "既存施設の最寄り駅をHeartRails APIで補完する（緯度経度または郵便番号を使用）"
  task enrich_stations: :environment do
    enriched = 0
    skipped  = 0

    WARD_CSV_URLS.each do |ward, url|
      begin
        raw = URI.open(url).read.force_encoding("UTF-8").encode("UTF-8", invalid: :replace, undef: :replace)
        raw.gsub!(/\A﻿/, "")

        CSV.parse(raw, headers: true) do |row|
          next unless row["バドミントン"] == "有"

          gym = Gym.find_by(name: row["名称"], ward: ward)
          next unless gym
          next if gym.nearest_station.present?

          # 郵便番号をDBに保存（まだ入っていない場合）
          if gym.postal_code.blank? && row["郵便番号"].present?
            gym.update_column(:postal_code, row["郵便番号"])
          end

          lat    = row["緯度"].presence
          lng    = row["経度"].presence
          postal = row["郵便番号"].presence

          station = if lat.present? && lng.present?
            fetch_nearest_station(lat, lng)
          elsif postal.present?
            fetch_nearest_station_by_postal(postal)
          end

          if station
            gym.update_column(:nearest_station, station)
            puts "#{gym.ward} #{gym.name} → #{station}"
            enriched += 1
            sleep(0.3)
          else
            skipped += 1
          end
        end

      rescue => e
        puts "#{ward} エラー: #{e.message}"
      end
    end

    puts "\n完了: #{enriched}件補完 / #{skipped}件スキップ"
  end
end
