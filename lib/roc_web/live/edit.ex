defmodule RocWeb.Live.Edit do
use RocWeb, :live_view
alias Roc.Repo
alias Roc.Subject

def mount(%{"id" => id}, _session, socket) do
    subject = Repo.get!(Subject,id)

    form =
      Subject.changeset(subject,%{})
      |> to_form()

    {:ok, assign(socket, form: form, subject: subject)}
  end


      def handle_event("validate_subject", %{"subject" => subject_params}, socket) do
        form =
          Subject.changeset(socket.assigns.subject, subject_params)
          |> Map.put(:action, :validate)
          |> to_form()

        {:noreply, assign(socket, form: form)}
      end
      def handle_event("save_subject", %{"subject" => subject_params}, socket) do
        subject = Subject.changeset(socket.assigns.subject, subject_params)
          Repo.update(subject)
          {:noreply,
          socket
          |> put_flash( :info, "Subject ID updated!")
          |> push_navigate(to: ~p"/new/index")

        }
        #     {:ok, _subject} ->

        #       {:noreply, put_flash(socket, :info, "Subject ID updated!")
        #       |> push_navigate(to: ~p"/page/index")}

        #     {:error, %Ecto.Changeset{} = changeset} ->
        #       form = to_form(changeset)

        #       socket
        #       |> assign(form: form)
        #       |> put_flash(:error, "Invalid data!")
        #   end
        #  {:noreply, socket}
        end
      end
