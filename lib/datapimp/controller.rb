class Datapimp::Controller < ActionController::Base
  include Datapimp::Filterable::ControllerMixin

  def create
    run_command
  end

  def update
    run_command
  end

  def destroy
    run_command
  end

  protected

  def requesting_javascript?
    request.format.symbol == :js
  end

  def requesting_json?
    request.format.symbol == :json
  end

  def requesting_user
    user_signed_in? ? current_user : User.anonymous
  end

  # What parameters get passed to the request will depend on what each command requires.  We try to standardize
  # on passing a reference to the user, and then whatever parameters are required for the command itself.  Trying
  # to stick with naming conventions.
  def command_params
    params
  end

  def outcome
    @outcome ||= command_runner.run(command).as(requesting_user).with(command_params).run
  end

  def run_command
    unless outcome.success?
      @errors = outcome.errors.message
    end

    instance_variable_set("@#{model_name}", outcome.result)
    send("respond_with_#{ request.format.symbol }")
  end

  def respond_with_js
    status = outcome.success? ? :ok : :bad_request
    render status: status
  end

  def respond_with_json
    if outcome.success?
      render :json => outcome.result, status: :ok
    else
      render :json => outcome.errors.message, status: :bad_request
    end
  end

  # Ultimately all POST, CREATE, PUT requests should get routed through the
  # command runner, which will take the current user, and the request they're making,
  # and automatically run the command and return the response.
  #
  # Example:
  #
  #   command_runner.run(command).as(current_user).with(params)
  def command_runner
    ApplicationCommand::Runner
  end

  # Which command we run wil be dependent on the HTTP Verb, and the name of the
  # controller.  Unless otherwise specified with certain request parameters that you
  # can set in your route definition
  def command
    resolve_command_class.to_s.classify
  end

  # Attempt to resolve which command to run to satisfy this request
  def resolve_command_class
    context_param     = params.fetch(:context, nil)
    command_param     = params.fetch(:command, nil)
    controller_klass  = self.class.name.split('::').last
    model_klass       = controller_klass.gsub(/Controller$/, '').singularize.camelize

    case
    when context_param.to_s.empty? && command_param.to_s.empty?
      [command_prefix, model_klass.underscore].join("_")
    when command_param
      command_param
    when context_param
      [command_prefix, context_param].join("_")
    end
  end

  def command_prefix
    case
    when request.post?
      "create"
    when request.put?
      "update"
    when request.delete?
      "destroy"
    end
  end

end
