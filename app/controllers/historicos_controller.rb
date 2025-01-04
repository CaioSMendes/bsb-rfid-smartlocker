class HistoricosController < ApplicationController
    def index
        @historicos = Log.all
        @history_entries = HistoryEntry.all
    end
end
