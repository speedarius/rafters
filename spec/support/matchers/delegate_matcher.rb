RSpec::Matchers.define :delegate do |method|
  match do |delegator|
    @method = @prefix ? :"#{@to}_#{method}" : method
    @delegator = delegator

    if @to.to_s[0] == '@'
      old_value = @delegator.instance_variable_get(@to)

      begin
        @delegator.instance_variable_set(@to, receiver_double(method))
        @delegator.send(@method) == :called
      ensure
        @delegator.instance_variable_set(@to, old_value)
      end
    elsif @delegator.respond_to?(@to, true)
      unless @delegator.method(@to).arity == 0
        raise "#{@delegator}'s' #{@to} method does not have zero arity (it expects parameters)"
      end

      @delegator.stub(@to).and_return receiver_double(method)
      @delegator.send(@method) == :called
    else
      raise "#{@delegator} does not respond to #{@to}"
    end
  end

  description do
    "delegate :#{@method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end

  failure_message_for_should do |text|
    "expected #{@delegator} to delegate :#{@method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end

  failure_message_for_should_not do |text|
    "expected #{@delegator} not to delegate :#{@method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end

  chain(:to) { |receiver| @to = receiver }
  chain(:with_prefix) { @prefix = true }

  def receiver_double(method)
    double('receiver').tap do |receiver|
      receiver.stub(method).and_return :called
    end
  end
end
