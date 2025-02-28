class HistoryChannel < ApplicationCable::Channel
  def subscribed
    stream_from "history_#{params[:keylocker_serial]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
