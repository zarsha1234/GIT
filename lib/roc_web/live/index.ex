defmodule RocWeb.Live.Index do
 use RocWeb, :live_view
 alias Roc.Repo
 alias Roc.Subject



def mount(_params,_session, socket) do
form=
  Subject.changeset(%Subject{},%{})
  |>to_form
  {:ok ,assign(socket, :form, form)}
 end

def handle_event("validate", %{"subject"=>roc_parmas},socket) do
 form=
  Subject.changeset(%Subject{},roc_parmas)
  |> Map.put(:action, :validate)
  |>to_form
  {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"subject"=>roc_params},socket)do
  IO.inspect({"Form submitted!!", roc_params})
  changeset = Subject.changeset(%Subject{}, roc_params)
   Repo.insert(changeset)



  end
end
