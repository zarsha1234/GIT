defmodule RocWeb.Live.List do
use RocWeb, :live_view
alias Roc.Repo
alias Roc.Subject
def mount(_parmas,_session, socket) do
   subject=Repo.all(Subject)
   {:ok, stream(socket, :subject, subject)}
   end

  def handle_event("delete", %{"id" => id}, socket) do
   subject = Repo.get!(Subject,id)
  {:ok, _} = Repo.delete(subject)

  {:noreply, stream_delete(socket, :subjects, subject)}
end

 end
