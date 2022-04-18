defmodule MinitwitElixir.PromEx.CustomMetrics do
  use PromEx.Plugin
  alias MinitwitElixir.Repo

  @impl true
  def polling_metrics(opts) do
    poll_rate = Keyword.get(opts, :poll_rate, 10_000)
    [
      memory_metrics(poll_rate)
    ]
  end

  defp memory_metrics(poll_rate) do
    Polling.build(
      :minitwit_elixir_custom_polling,
      poll_rate,
      {__MODULE__, :latest_counts, []},
      [
        last_value(
          [:minitwit_elixir, :custom, :users, :count],
          event_name: [:minitwit_elixir, :users, :count],
          description: "Number of users in the db",
          measurement: :count
        ),
        last_value(
          [:minitwit_elixir, :custom, :messages, :count],
          event_name: [:minitwit_elixir, :messages, :count],
          description: "Number of messages in the db",
          measurement: :count
        ),
        last_value(
          [:minitwit_elixir, :custom, :flagged_messages, :count],
          event_name: [:minitwit_elixir, :flagged_messages, :count],
          description: "Number of flagged messages in the db",
          measurement: :count
        ),
      ]
    )
  end

  @doc false
  def latest_counts do

    mets = Enum.at(Repo.all(MinitwitElixir.Schemas.Metrics), 0)

    :telemetry.execute([:minitwit_elixir, :tweet, :success], %{count: mets.minitwit_elixir_tweet_success})
    :telemetry.execute([:minitwit_elixir, :tweet, :not_authorized], %{count: mets.minitwit_elixir_tweet_not_authorized})
    :telemetry.execute([:minitwit_elixir, :tweet, :user_dont_exist], %{count: mets.minitwit_elixir_tweet_user_dont_exist})

    :telemetry.execute([:minitwit_elixir, :register, :username_missing], %{count: mets.minitwit_elixir_register_username_missing})
    :telemetry.execute([:minitwit_elixir, :register, :email_not_valid], %{count: mets.minitwit_elixir_register_email_not_valid})
    :telemetry.execute([:minitwit_elixir, :register, :password_missing], %{count: mets.minitwit_elixir_register_password_missing})
    :telemetry.execute([:minitwit_elixir, :register, :passwords_dont_match], %{count: mets.minitwit_elixir_register_passwords_dont_match})
    :telemetry.execute([:minitwit_elixir, :register, :username_taken], %{count: mets.minitwit_elixir_register_username_taken})
    :telemetry.execute([:minitwit_elixir, :register, :success], %{count: mets.minitwit_elixir_register_success})

    :telemetry.execute([:minitwit_elixir, :public_timeline, :success], %{count: mets.minitwit_elixir_public_timeline_success})
    :telemetry.execute([:minitwit_elixir, :public_timeline, :not_authorized], %{count: mets.minitwit_elixir_public_timeline_not_authorized})
    :telemetry.execute([:minitwit_elixir, :my_timeline, :success], %{count: mets.minitwit_elixir_my_timeline_success})
    :telemetry.execute([:minitwit_elixir, :user_timeline, :success], %{count: mets.minitwit_elixir_user_timeline_success})
    :telemetry.execute([:minitwit_elixir, :user_timeline, :not_authorized], %{count: mets.minitwit_elixir_user_timeline_not_authorized})

    :telemetry.execute([:minitwit_elixir, :get_followers, :success], %{count: mets.minitwit_elixir_get_followers_success})
    :telemetry.execute([:minitwit_elixir, :get_followers, :user_dont_exist], %{count: mets.minitwit_elixir_get_followers_user_dont_exist})
    :telemetry.execute([:minitwit_elixir, :get_followers, :not_authorized], %{count: mets.minitwit_elixir_get_followers_not_authorized})

    :telemetry.execute([:minitwit_elixir, :post_followers, :follow, :success], %{count: mets.minitwit_elixir_post_followers_follow_success})
    :telemetry.execute([:minitwit_elixir, :post_followers, :follow, :other_dont_exist], %{count: mets.minitwit_elixir_post_followers_follow_other_dont_exist})
    :telemetry.execute([:minitwit_elixir, :post_followers, :unfollow, :success], %{count: mets.minitwit_elixir_post_followers_unfollow_success})
    :telemetry.execute([:minitwit_elixir, :post_followers, :unfollow, :other_dont_exist], %{count: mets.minitwit_elixir_post_followers_unfollow_other_dont_exist})
    :telemetry.execute([:minitwit_elixir, :post_followers, :action_missing], %{count: mets.minitwit_elixir_post_followers_action_missing})
    :telemetry.execute([:minitwit_elixir, :post_followers, :user_dont_exist], %{count: mets.minitwit_elixir_post_followers_user_dont_exist})
    :telemetry.execute([:minitwit_elixir, :post_followers, :not_authorized], %{count: mets.minitwit_elixir_public_timeline_not_authorized})

    :telemetry.execute([:minitwit_elixir, :latest, :count], %{count: mets.minitwit_elixir_latest_count})
    :telemetry.execute([:minitwit_elixir, :api_requests, :count], %{count: mets.minitwit_elixir_api_requests_count})

    :telemetry.execute([:minitwit_elixir, :users], %{count: MinitwitElixir.Schemas.User.get_user_count()})
    :telemetry.execute([:minitwit_elixir, :messages], %{count: MinitwitElixir.Schemas.Message.get_message_count()})
    :telemetry.execute([:minitwit_elixir, :flagged_messages], %{count: MinitwitElixir.Schemas.Message.get_flagged_message_count()})
  end

  @impl true
  def event_metrics(_opts) do
    [
      Event.build(
        :minitwit_elixir_custom,
        [
          # Counters for tweets
          last_value(
            [:minitwit_elixir, :custom, :tweet, :success],
            event_name: [:minitwit_elixir, :tweet, :success],
            description: "Number of tweet success",
            measurement: :count
          ),
          last_value(
            [:minitwit_elixir, :custom, :tweet, :not_authorized],
            event_name: [:minitwit_elixir, :tweet, :not_authorized],
            description: "Number of tweet errors due to not being authorized",
            measurement: :count
          ),
          last_value(
            [:minitwit_elixir, :custom, :tweet, :user_dont_exist],
            event_name: [:minitwit_elixir, :tweet, :user_dont_exist],
            description: "Number of tweet errors due to user not existing",
            measurement: :count
          ),

          # Counters for register errors
          last_value(
            [:minitwit_elixir, :custom, :register, :username_missing],
            event_name: [:minitwit_elixir, :register, :username_missing],
            description: "User could not be registered due to username missing",
            measurement: :count
          ),
          last_value(
            [:minitwit_elixir, :custom, :register, :email_not_valid],
            event_name: [:minitwit_elixir, :register, :email_not_valid],
            description: "User could not be registered due to email not being valid",
            measurement: :count
          ),
          last_value(
            [:minitwit_elixir, :custom, :register, :password_missing],
            event_name: [:minitwit_elixir, :register, :password_missing],
            description: "User could not be registered due to password missing",
            measurement: :count
          ),
          last_value(
            [:minitwit_elixir, :custom, :register, :passwords_dont_match],
            event_name: [:minitwit_elixir, :register, :passwords_dont_match],
            description: "User could not be registered due to passwords not matching",
            measurement: :count
          ),
          last_value(
            [:minitwit_elixir, :custom, :register, :username_taken],
            event_name: [:minitwit_elixir, :register, :username_taken],
            description: "User could not be registered due to username being taken",
            measurement: :count
          ),
          last_value(
            [:minitwit_elixir, :custom, :register, :success],
            event_name: [:minitwit_elixir, :register, :success],
            description: "User registered successfully",
            measurement: :count
          ),

          # Counters for get all messages
          last_value(
            [:minitwit_elixir, :custom, :public_timeline, :success],
            event_name: [:minitwit_elixir, :public_timeline, :success],
            description: "Request for public timeline success",
            measurement: :count
          ),
          last_value(
            [:minitwit_elixir, :custom, :public_timeline, :not_authorized],
            event_name: [:minitwit_elixir, :public_timeline, :not_authorized],
            description: "Request for public timeline not authorized",
            measurement: :count
          ),

          # Counters for get my timeline
          last_value(
            [:minitwit_elixir, :custom, :my_timeline, :success],
            event_name: [:minitwit_elixir, :my_timeline, :success],
            description: "Request for my timeline success",
            measurement: :count
          ),

          # Counters for get user messages
          last_value(
            [:minitwit_elixir, :custom, :user_timeline, :success],
            event_name: [:minitwit_elixir, :user_timeline, :success],
            description: "Request for user timeline success",
            measurement: :count
          ),
          last_value(
            [:minitwit_elixir, :custom, :user_timeline, :not_authorized],
            event_name: [:minitwit_elixir, :user_timeline, :not_authorized],
            description: "Request for user timeline not authorized",
            measurement: :count
          ),

          # Counters for get followers
          last_value(
            [:minitwit_elixir, :custom, :get_followers, :success],
            event_name: [:minitwit_elixir, :get_followers, :success],
            description: "Request for get followers success",
            measurement: :count
          ),
          last_value(
            [:minitwit_elixir, :custom, :get_followers, :user_dont_exist],
            event_name: [:minitwit_elixir, :get_followers, :user_dont_exist],
            description: "Request for get followers due to user doesnt exist",
            measurement: :count
          ),
          last_value(
            [:minitwit_elixir, :custom, :get_followers, :not_authorized],
            event_name: [:minitwit_elixir, :get_followers, :not_authorized],
            description: "Request for get followers not authorized",
            measurement: :count
          ),

          # Counters for post followers
          last_value(
            [:minitwit_elixir, :custom, :post_followers, :follow, :success],
            event_name: [:minitwit_elixir, :post_followers, :follow, :success],
            description: "Post followers follow success",
            measurement: :count
          ),
          last_value(
            [:minitwit_elixir, :custom, :post_followers, :follow, :other_dont_exist],
            event_name: [:minitwit_elixir, :post_followers, :follow, :other_dont_exist],
            description: "Post followers follow other name could not be found",
            measurement: :count
          ),
          last_value(
            [:minitwit_elixir, :custom, :post_followers, :unfollow, :success],
            event_name: [:minitwit_elixir, :post_followers, :unfollow, :success],
            description: "Post followers unfollow success",
            measurement: :count
          ),
          last_value(
            [:minitwit_elixir, :custom, :post_followers, :unfollow, :other_dont_exist],
            event_name: [:minitwit_elixir, :post_followers, :unfollow, :other_dont_exist],
            description: "Post followers unfollow other name could not be found",
            measurement: :count
          ),

          last_value(
            [:minitwit_elixir, :custom, :post_followers, :action_missing],
            event_name: [:minitwit_elixir, :post_followers, :action_missing],
            description: "Post followers action was missing",
            measurement: :count
          ),
          last_value(
            [:minitwit_elixir, :custom, :post_followers, :user_dont_exist],
            event_name: [:minitwit_elixir, :post_followers, :user_dont_exist],
            description: "Post followers user doesnt exist",
            measurement: :count
          ),
          last_value(
            [:minitwit_elixir, :custom, :post_followers, :not_authorized],
            event_name: [:minitwit_elixir, :post_followers, :not_authorized],
            description: "Post followers not authorized",
            measurement: :count
          ),

          # Counter for latest
          last_value(
            [:minitwit_elixir, :custom, :latest, :count],
            event_name: [:minitwit_elixir, :latest, :count],
            description: "The number of times latest has been requested",
            measurement: :count
          ),
          last_value(
            [:minitwit_elixir, :custom, :api_requests, :count],
            event_name: [:minitwit_elixir, :api_requests, :count],
            description: "The number of times the api was called",
            measurement: :count
          ),
        ]
      )
    ]
  end
end