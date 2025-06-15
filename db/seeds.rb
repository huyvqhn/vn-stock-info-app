# db/seeds.rb

GROUPS_WITH_TICKERS = {
  "BANK" => %w[ABB ACB BAB BID BVB CTG EIB EVF HDB KLB LPB MBB MSB NAB NVB OCB PGB SHB SSB STB TCB TPB VBB VCB VIB VPB],
  "CaoSu" => %w[DRC DRI DPR GVR PHR TRC CSM],
  "ChungKhoan" => %w[AAS AGR APG APS BCG BMS BSI BVS CTS EVS FTS HBS HCM IVS MBS ORS PSI SBS SHS SSI TCI TVB TVC TVS VCI VDS VFS VIG VIX VND WSS],
  "BaoHiem" => %w[ABI BIC BMI BVH IMG MIG PTI PVI VNR],
  "KimLoai" => %w[HMC HPG HSG HSV ITQ KVC NKG NSH SHI SMC TLH TVN VGS],
  "BDS" => %w[AAV AGG CCL CKG CSC DIG DPG DRA DTA DXG DXS FIR FIT KDH HAG HDC HDG HLD HPX IDJ KHG KOS LDG NHA NLG NTL NVL PDR PWA PXL SCR SJS TAL TCH TDC TEG THD VCR VGC VHM VIC VPI VPH VPL VRC VRE],
  "BDS-KhuCN" => %w[BCM CTD D2D IDC IJC KBC LHG NTC SIP SNZ SZC SZL TIP VC3],
  "CongNghe" => %w[CMG ELC FPT ICT MFS SAM SGT ST8 VGI FOX],
  "BanLe" => %w[AST DAH DGW DST FRT MWG MSN PET PNJ PSD VNB VTD VNM],
  "HangTieuDung" => %w[BAV BNA GDT HAX HHS HNG IDI KDC LIX MCM NAF PPH SAB TDT TID TLG VOC],
  "NongNghiep" => %w[AFX HAG PAN TSC NSC],
  "MiaDuong" => %w[KTS LSS QNS SBT],
  "ThitLon" => %w[BAF DBC HAG],
  "DauKhi" => %w[BSR GAS OIL PLX PPS PVC PVB PVD PVS],
  "VanTai" => %w[ACV CTI DAH DST GMD GSP HAH HHV HVN ILB MVN PHP PVT SAS SCS SGP SGN SKG TCL TCO VJC VIP VOS VSC VTP VTO],
  "Nhua" => %w[AAA BMP NHH NTP VCS],
  "SP-DV-CNghiep" => %w[DLG DDG DXP GEX GEE HHG LPT MHC NAG PC1 PSP PVP REE SDA SWC TCD TNI TV2 VEA VNA YEG],
  "TaiNguyen" => %w[BMC CST DCM DHM KSB KSQ MSR MVB NBC TNT THT TVD VPG],
  "ThuySan" => %w[ACL ANV ASM CMX FMB MPC VHC],
  "YTe" => %w[DBD DBT DCL DMC DDN DHT DVN IMP JVC LDP TNH],
  "LamNghiep-Giay" => %w[BKG DHC HAP HHP],
  "HoaChat" => %w[ABS APH CSV DCM DGC DPM HII HVT PLC PLP PMB SBV STK TDP VHG VNP VPS],
  "PhanBon" => %w[BFC DAP DDV LAS],
  "DetMay" => %w[ADS MSH TCM TNG VGT GIL],
  "DichVuHaTang" => %w[ASP BTP BWE CNG GEG HND HTI KHP NT2 PGN PGC PPC POW PVG QTP SJD TDM TTA VSH VCW],
  "XD-VLXD" => %w[BCE BCC BTS C32 C4G C69 CRC CTI CTR DXP HOM HTI HTN HUT HVH IDC L14 LCG PHC TLD VCG VNE VC7],
  "Lctv20" => %w[MBB HDB TCB HPG HSG SSI HCM POW DBC MSN],
  "Vn30" => %w[FPT VHM VNM ACB BID BVH CTG GAS HPG HSG KDH MBB MSN MWG NVL PDR PLX POW SAB SBT SSI STB TCB TPB VCB VIC VJC VRE VPB],
  "CoTuc" => %w[CAP CHP D2D DHA DHG GAS NBC NCT NT2 PGC PSD SAB SCS SD5 TIP TMP TVD VCS VIP VTO NTL]
}

GROUPS_WITH_TICKERS.each do |group_name, tickers|
  group = Group.find_or_create_by!(name: group_name)
  tickers.each do |symbol|
    # Only create ticker if it does not exist (by symbol)
    Ticker.find_or_create_by!(symbol: symbol) do |ticker|
      ticker.group = group
    end
  end
end

require 'csv'

define_tickers_csv_path = Rails.root.join('app', 'assets', 'seeds', 'define_tickers_2025_05_24.csv')

def find_group_for_ticker(symbol)
  GROUPS_WITH_TICKERS.each do |group_name, tickers|
    return Group.find_by(name: group_name) if tickers.include?(symbol)
  end
  nil
end

# CSV.foreach(define_tickers_csv_path, headers: true) do |row|
#   group = find_group_for_ticker(row['Symbol'])
#   next unless group # skip if no group found

#   # Only update ticker if it already exists (by symbol)
#   ticker = Ticker.find_by(symbol: row['Symbol'])
#   if ticker && ticker.group == group
#     ticker.exchange = row['Exchange']
#     ticker.sector = row['Sector']
#     ticker.industry = row['Industry']
#     ticker.description = row['Description']
#     ticker.is_active = true
#     ticker.beta = row['Beta 5 years']
#     ticker.dividend_yield_ttm = row['Dividend yield %, Trailing 12 months']
#     ticker.save!
#   end
# end

stock_prices_csv_path = Rails.root.join('app', 'assets', 'seeds', 'stock_prices.csv')

CSV.foreach(stock_prices_csv_path, headers: true) do |row|
  # Ticker	recorded_at	Price	% Change	matching_volume_self	matching_volume_foreign	volume

  ticker = Ticker.find_by(symbol: row['Ticker'])
  # debugger
  next unless ticker
  recorded_at = row['recorded_at'] ? Date.parse(row['recorded_at']) : Date.today
  next if row['volume'].blank? || row['Price'].blank?
  unless StockPrice.exists?(ticker: ticker, recorded_at: recorded_at)
    StockPrice.create!(
      ticker: ticker,
      price: row['Price'],
      volume: row['volume'],
      percent_change: row['Percent_Change'],
      matching_volume_foreign: row['matching_volume_foreign'],
      matching_volume_self: row['matching_volume_self'],
      recorded_at: recorded_at,
      average_price: row['Average Price'],
      total_trading: row['Total Trading'],
      total_trading_value: row['Total Trading Value'],
      foreign_room: row['Foreign Room'],
      foreign_remain: row['Foreign Remain']
    )
  end
end
