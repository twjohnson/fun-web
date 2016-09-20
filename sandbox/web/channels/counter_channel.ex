defmodule Secounter.CounterChannel do
  use Secounter.Web, :channel

  def join("counter:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("increment", payload, socket) do
    broadcast! socket, "increment", %{"body" => "#{impose_payload(payload) + 1}"}
    {:noreply, socket}
  end

  def handle_in("decrement", payload, socket) do
    broadcast! socket, "decrement", %{"body" => "#{impose_payload(payload) - 1}"}
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  defp impose_payload(payload) do
    String.to_integer(payload["body"])
  end
end
