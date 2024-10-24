defmodule RocWeb.UserSettingsLive do
  use RocWeb, :live_view

  alias Roc.Accounts
  alias Roc.Repo

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Account Settings
      <:subtitle>Manage your account email address and password settings</:subtitle>
    </.header>


      <div>
        <.simple_form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
        >
          <.input field={@email_form[:email]} type="email" label="Email" required />
          <.input
            field={@email_form[:current_password]}
            name="current_password"
            id="current_password_for_email"
            type="password"
            label="Current password"
            value={@email_form_current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Email</.button>
          </:actions>
        </.simple_form>
      </div>
      <div>
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <input
            name={@password_form[:email].name}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
          />
          <.input field={@password_form[:password]} type="password" label="New password" required />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label="Confirm new password"
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label="Current password"
            id="current_password_for_password"
            value={@current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Password</.button>
          </:actions>
        </.simple_form>
        <div>

        <.simple_form
          for={@time_form}
          id="time_zone_form"
          phx-submit="save_time_zone"
          phx-change="validate_time_zone"
        >

        <.input field={@time_form[:time_zone]} type="select" label="Time Zone" required options={@time_zone_options} />
         <.input field={@time_form[:time_format]} type="select" label="Time Format" required options={@time_format_options} />
         <.input field={@time_form[:date_format]} type="select" label="Date Format" required options={@date_format_options} />
          <:actions>
           <h3>Current Time:</h3>
        <p>Current Time: <%= @current_time %></p>

            <.button phx-disable-with="Saving...">Save</.button>

          </:actions>
        </.simple_form>
      </div>




    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)
    time_changeset = Accounts.change_user_time(user)
    user_time_zone = socket.assigns.current_user.time_zone || "UTC"
    user_time_format = socket.assigns.current_user.time_format || "12_hour"
    user_date_format = socket.assigns.current_user.date_format || "%d-%m-%y"


 time_zone_options = Tzdata.zone_list() |> IO.inspect()
  time_format_options =
  [
      {"12-hour (AM/PM)", "%I:%M %p"},
      {"12-hour (am/pm)", "%I:%M %P"} ,
      {"24-hour", "%H:%M"}
  ]

    date_format_options = [
      {"DD/MM/YYYY", "%d/%m/%Y"},
      {"MM/DD/YYYY", "%m/%d/%Y"},
      {"YYYY-MM-DD", "%Y-%m-%d"}
    ]

    socket =
      socket
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:time_form, to_form(time_changeset))
      |> assign(:time_zone_options, time_zone_options)
      |> assign(:time_format_options, time_format_options)
      |> assign(:date_format_options, date_format_options)
      |> assign(:trigger_submit, false)
      |> assign(:current_time, get_current_time(user))
      |> assign(:user_time_zone, user_time_zone)
      |> assign(:user_time_format, user_time_format)
      |> assign(:user_date_format, user_date_format)
IO.inspect(get_current_time(user))
    {:ok, socket}
    end

  defp get_current_time(user) do
    time_zone =  user.time_zone
    time_format = user.time_format
    date_format = user.date_format


    {:ok, now} =DateTime.shift_zone(DateTime.utc_now(), time_zone)

    combined_format = date_format <> " " <> time_format
    Calendar.strftime(now, combined_format)
  end


  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end


  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end

  end
     def handle_event("validate_time_zone", %{"user"=>params}, socket) do

  time_zone_form =
     socket.assigns.current_user
     |> Accounts.change_user_time(params)
     |> to_form()
     {:noreply, assign(socket, :time_form, time_zone_form)}
  end



def handle_event("save_time_zone", %{"user"=>params}, socket) do
 changeset =
    socket.assigns.current_user
    |> Accounts.change_user_time(params)
    IO.inspect(changeset)
   Repo.update(changeset)

  {:noreply, assign(socket, :time_form, to_form(changeset))}
end

end
