class TickersController < ApplicationController
  def index
    @tickers = Ticker.all
  end
end
