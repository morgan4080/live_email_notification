defmodule LiveEmailNotificationWeb.Router do
  use LiveEmailNotificationWeb, :router
  
  import LiveEmailNotificationWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LiveEmailNotificationWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug :fetch_current_user
    plug :set_path
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", LiveEmailNotificationWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:live_email_notification, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LiveEmailNotificationWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/", LiveEmailNotificationWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/", PageController, :home
  end

  ## Authentication routes

  scope "/", LiveEmailNotificationWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
                 on_mount: [{LiveEmailNotificationWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", LiveEmailNotificationWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
                 on_mount: [{LiveEmailNotificationWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", LiveEmailNotificationWeb do
    pipe_through [:browser, :require_authenticated_user]

    delete "/users/log_out", UserSessionController, :delete

    live_session :authenticated_user,
                 on_mount: [{LiveEmailNotificationWeb.UserAuth, :mount_current_path},{LiveEmailNotificationWeb.UserAuth, :mount_current_user}],
                 root_layout: {LiveEmailNotificationWeb.Layouts, :authenticated} do
      live "/dashboard", DashboardLive, :index
      live "/contacts", ContactLive, :index
      live "/emails", EmailLive, :index
      live "/emails/:email_id/contacts", EmailContactsLive, :index
      live "/contact/:contact_id/emails", EmailLive, :index
      live "/paywall", PayWallLive, :index # show user plan
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end


  scope "/", LiveEmailNotificationWeb do
    pipe_through [:browser, :require_authenticated_user_gold]

    live_session :authenticated_user_gold,
                 on_mount: [{LiveEmailNotificationWeb.UserAuth, :mount_current_path},{LiveEmailNotificationWeb.UserAuth, :mount_current_user}],
                 root_layout: {LiveEmailNotificationWeb.Layouts, :authenticated} do
      live "/groups", GroupLive, :index
      live "/group/:group_id/emails", EmailLive, :groupemails
    end
  end

  scope "/", LiveEmailNotificationWeb do
    pipe_through [:browser, :require_authenticated_user_admin]

    live_session :authenticated_user_admin,
                 on_mount: [
                   {LiveEmailNotificationWeb.UserAuth, :mount_current_user},
                   {LiveEmailNotificationWeb.UserAuth, :mount_selected_user},
                   {LiveEmailNotificationWeb.UserAuth, :mount_uuid},
                   {LiveEmailNotificationWeb.UserAuth, :mount_current_path}
                 ],
                 root_layout: {LiveEmailNotificationWeb.Layouts, :authenticated} do
      live "/admin/users", UserLive, :admin
      live "/admin/users/:uuid/dashboard", DashboardLive, :admin
      live "/admin/users/:uuid/contacts", ContactLive, :admin
      live "/admin/users/:uuid/emails", EmailLive, :admin
      live "/admin/users/:uuid/emails/:email_id/contacts", EmailContactsLive, :admin
    end
  end

  scope "/", LiveEmailNotificationWeb do
    pipe_through [:browser, :require_authenticated_user_admin_gold]

    live_session :authenticated_user_admin_gold,
                 on_mount: [
                   {LiveEmailNotificationWeb.UserAuth, :mount_current_user},
                   {LiveEmailNotificationWeb.UserAuth, :mount_selected_user},
                   {LiveEmailNotificationWeb.UserAuth, :mount_uuid},
                   {LiveEmailNotificationWeb.UserAuth, :mount_current_path}
                 ],
                 root_layout: {LiveEmailNotificationWeb.Layouts, :authenticated} do
      live "/admin/users/:uuid/groups", GroupLive, :admin
      live "/admin/users/:uuid/group/:id/emails", EmailLive, :admin_group
    end
  end

  defp set_path(conn, _opts) do
    Plug.Conn.put_session(conn, :current_path, conn.request_path)
  end
end
