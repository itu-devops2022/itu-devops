defmodule MinitwitElixir.PromEx.CustomMetrics do
  use PromEx.Plugin

  @user_count [:minitwit_elixir, :users]
  @message_count [:minitwit_elixir, :messages]
  @flagged_message_count [:minitwit_elixir, :flagged_messages]

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
          event_name: @user_count,
          description: "Number of users in the db",
          measurement: :count
        ),
        last_value(
          [:minitwit_elixir, :custom, :messages, :count],
          event_name: @message_count,
          description: "Number of messages in the db",
          measurement: :count
        ),
        last_value(
          [:minitwit_elixir, :custom, :flagged_messages, :count],
          event_name: @flagged_message_count,
          description: "Number of flagged messages in the db",
          measurement: :count
        )
        # More memory metrics here
      ]
    )
  end

  @doc false
  def latest_counts do
    :telemetry.execute(@user_count, %{count: MinitwitElixir.Schemas.User.get_user_count()})
    :telemetry.execute(@message_count, %{count: MinitwitElixir.Schemas.Message.get_message_count()})
    :telemetry.execute(@flagged_message_count, %{count: MinitwitElixir.Schemas.Message.get_flagged_message_count()})
  end

  @impl true
  def event_metrics(_opts) do
    [
      Event.build(
        :minitwit_elixir_custom,
        [
          # Counters for tweets
          counter(
            [:minitwit_elixir, :custom, :tweet, :success],
            event_name: [:minitwit_elixir, :tweet, :success],
            description: "Number of tweet success",
            measurement: :count
          ),
          counter(
            [:minitwit_elixir, :custom, :tweet, :not_authorized],
            event_name: [:minitwit_elixir, :tweet, :not_authorized],
            description: "Number of tweet errors due to not being authorized",
            measurement: :count
          ),
          counter(
            [:minitwit_elixir, :custom, :tweet, :user_dont_exist],
            event_name: [:minitwit_elixir, :tweet, :user_dont_exist],
            description: "Number of tweet errors due to user not existing",
            measurement: :count
          ),

          # Counters for register errors
          counter(
            [:minitwit_elixir, :custom, :register, :username_missing],
            event_name: [:minitwit_elixir, :register, :username_missing],
            description: "User could not be registered due to username missing",
            measurement: :count
          ),
          counter(
            [:minitwit_elixir, :custom, :register, :email_not_valid],
            event_name: [:minitwit_elixir, :register, :email_not_valid],
            description: "User could not be registered due to email not being valid",
            measurement: :count
          ),
          counter(
            [:minitwit_elixir, :custom, :register, :password_missing],
            event_name: [:minitwit_elixir, :register, :password_missing],
            description: "User could not be registered due to password missing",
            measurement: :count
          ),
          counter(
            [:minitwit_elixir, :custom, :register, :passwords_dont_match],
            event_name: [:minitwit_elixir, :register, :passwords_dont_match],
            description: "User could not be registered due to passwords not matching",
            measurement: :count
          ),
          counter(
            [:minitwit_elixir, :custom, :register, :username_taken],
            event_name: [:minitwit_elixir, :register, :username_taken],
            description: "User could not be registered due to username being taken",
            measurement: :count
          ),
          counter(
            [:minitwit_elixir, :custom, :register, :success],
            event_name: [:minitwit_elixir, :register, :success],
            description: "User registered successfully",
            measurement: :count
          ),

          # Counters for get all messages
          counter(
            [:minitwit_elixir, :custom, :public_timeline, :success],
            event_name: [:minitwit_elixir, :public_timeline, :success],
            description: "Request for public timeline success",
            measurement: :count
          ),
          counter(
            [:minitwit_elixir, :custom, :public_timeline, :not_authorized],
            event_name: [:minitwit_elixir, :public_timeline, :not_authorized],
            description: "Request for public timeline not authorized",
            measurement: :count
          ),

          # Counters for get my timeline
          counter(
            [:minitwit_elixir, :custom, :my_timeline, :success],
            event_name: [:minitwit_elixir, :my_timeline, :success],
            description: "Request for my timeline success",
            measurement: :count
          ),

          # Counters for get user messages
          counter(
            [:minitwit_elixir, :custom, :user_timeline, :success],
            event_name: [:minitwit_elixir, :user_timeline, :success],
            description: "Request for user timeline success",
            measurement: :count
          ),
          counter(
            [:minitwit_elixir, :custom, :user_timeline, :not_authorized],
            event_name: [:minitwit_elixir, :user_timeline, :not_authorized],
            description: "Request for user timeline not authorized",
            measurement: :count
          ),

          # Counters for get followers
          counter(
            [:minitwit_elixir, :custom, :get_followers, :success],
            event_name: [:minitwit_elixir, :get_followers, :success],
            description: "Request for get followers success",
            measurement: :count
          ),
          counter(
            [:minitwit_elixir, :custom, :get_followers, :user_dont_exist],
            event_name: [:minitwit_elixir, :get_followers, :user_dont_exist],
            description: "Request for get followers due to user doesnt exist",
            measurement: :count
          ),
          counter(
            [:minitwit_elixir, :custom, :get_followers, :not_authorized],
            event_name: [:minitwit_elixir, :get_followers, :not_authorized],
            description: "Request for get followers not authorized",
            measurement: :count
          ),

          # Counters for post followers
          counter(
            [:minitwit_elixir, :custom, :post_followers, :follow, :success],
            event_name: [:minitwit_elixir, :post_followers, :follow, :success],
            description: "Post followers follow success",
            measurement: :count
          ),
          counter(
            [:minitwit_elixir, :custom, :post_followers, :follow, :other_dont_exist],
            event_name: [:minitwit_elixir, :post_followers, :follow, :other_dont_exist],
            description: "Post followers follow other name could not be found",
            measurement: :count
          ),
          counter(
            [:minitwit_elixir, :custom, :post_followers, :unfollow, :success],
            event_name: [:minitwit_elixir, :post_followers, :unfollow, :success],
            description: "Post followers unfollow success",
            measurement: :count
          ),
          counter(
            [:minitwit_elixir, :custom, :post_followers, :unfollow, :other_dont_exist],
            event_name: [:minitwit_elixir, :post_followers, :unfollow, :other_dont_exist],
            description: "Post followers unfollow other name could not be found",
            measurement: :count
          ),

          counter(
            [:minitwit_elixir, :custom, :post_followers, :action_missing],
            event_name: [:minitwit_elixir, :post_followers, :action_missing],
            description: "Post followers action was missing",
            measurement: :count
          ),
          counter(
            [:minitwit_elixir, :custom, :post_followers, :user_dont_exist],
            event_name: [:minitwit_elixir, :post_followers, :user_dont_exist],
            description: "Post followers user doesnt exist",
            measurement: :count
          ),
          counter(
            [:minitwit_elixir, :custom, :post_followers, :not_authorized],
            event_name: [:minitwit_elixir, :post_followers, :not_authorized],
            description: "Post followers not authorized",
            measurement: :count
          ),

          # Counter for latest
          counter(
            [:minitwit_elixir, :custom, :latest, :count],
            event_name: [:minitwit_elixir, :latest, :count],
            description: "The number of times latest has been requested",
            measurement: :count
          ),
          counter(
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