# frozen_string_literal: true

# Centralized API endpoints for market data providers
# Usage: MarketApiEndpoints::SELF_VPS, MarketApiEndpoints::Proprietary_HNX, etc.
class MarketApiEndpoints
  # Tu Doanh (Proprietary Trading)
  PROPRIETARY_VPS = "https://histdatafeed.vps.com.vn/proprietary/snapshot/TOTAL"
  # TU_DOANH_CAFEF = "https://cafef.vn/du-lieu/Ajax/PageNew/DataHistory/GDTuDoanh.ashx?Symbol=VHM&PageIndex=1&PageSize=1"

  # Total + NN (Foreign)
  TOTAL_NN_BVSC = "https://online.bvsc.com.vn/datafeed/instruments"
  # TOTAL_NN_SSI = "https://iboard-api.ssi.com.vn/statistics/company/stock-price?symbol=VHM&page=1&pageSize=1"

  # Thoa Thuan (Put-through/Negotiated)
  NEGOTIATE_HNX_BVSC = "https://online.bvsc.com.vn/datafeed/ptmatch/HNX"
  NEGOTIATE_HOSE_BVSC = "https://online.bvsc.com.vn/datafeed/ptmatch/HOSE"
  NEGOTIATE_UPCOM_BVSC = "https://online.bvsc.com.vn/datafeed/ptmatch/UPCOM"

  # Add more endpoints here as needed
end
