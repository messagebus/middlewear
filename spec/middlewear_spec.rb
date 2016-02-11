require 'spec_helper'

RSpec.describe Middlewear do
  subject(:middlewear) do
    m = Module.new
    m.send(:include, Middlewear)
    m
  end

  class MiddlewareAddLetter
    def initialize(app, letter)
      @app = app
      @letter = letter
    end

    def call(message)
      message['letter'] = @letter
      @app.call(message)
    end
  end

  class MiddlewareNoop
    def initialize(app)
      @app = app
    end

    def call(message)
      @app.call(message)
    end
  end

  class RaisingMiddleware
    def initialize(app)
      @app = app
    end

    def call(_message)
      raise StandardError.new('Raise')
    end
  end

  class CatchingMiddleWare
    def initialize(app)
      @app = app
    end

    def call(message)
      @app.call(message)
    rescue StandardError => e
      message['error_message'] = e.message
    end
  end

  let(:metadata) { double('metadata', ack: true) }
  let(:payload) { '{}' }
  let(:message) { {} }
  let(:registry) { middlewear.registry }

  describe '.add' do
    it 'changes the index of the middleware' do
      expect {
        middlewear.add MiddlewareAddLetter, 'f'
      }.to change { middlewear.registry.index_of(MiddlewareAddLetter) }.to(0)
    end

    context 'when duplicate middleware is added' do
      it 'raises' do
        middlewear.add MiddlewareAddLetter, 'f'
        expect {
          middlewear.add MiddlewareAddLetter, 'f'
        }.to raise_error(Middlewear::DuplicateMiddleware)
      end
    end
  end

  describe '.delete' do
    before do
      middlewear.add MiddlewareAddLetter, 'f'
    end

    it 'removes register that matches class name' do
      expect(registry.index_of(MiddlewareAddLetter)).to be
      middlewear.delete(MiddlewareAddLetter)
      expect(registry.index_of(MiddlewareAddLetter)).not_to be
    end
  end

  describe '.add_before' do
    it 'changes order of middleware' do
      middlewear.add MiddlewareAddLetter, 'f'
      expect {
        middlewear.add_before MiddlewareAddLetter, MiddlewareNoop
      }.to change { registry.index_of(MiddlewareAddLetter) }.from(0).to(1)
      expect(registry.index_of(MiddlewareNoop)).to eq(0)
    end
  end

  context '.add_after' do
    it 'changes order of middleware' do
      middlewear.add MiddlewareAddLetter, 'f'
      middlewear.add CatchingMiddleWare, 'f'
      expect {
        middlewear.add_after MiddlewareAddLetter, MiddlewareNoop
      }.to change { registry.index_of(CatchingMiddleWare) }.from(1).to(2)
    end
  end

  describe '#app' do
    it 'can modify data passed into the stack' do
      middlewear.add MiddlewareAddLetter, 'f'
      expect {
        middlewear.app.call(message) do |message|
        end
      }.to change { message['letter'] }.from(nil).to('f')
    end

    it 'executes block passed to call method' do
      middlewear.add MiddlewareAddLetter, 'f'
      expectation = double(called: true)
      middlewear.app.call(message) do |message|
        expectation.called
      end
      expect(expectation).to have_received(:called)
    end

    it 'can be called without a block' do
      middlewear.add MiddlewareAddLetter, 'f'
      expect {
        middlewear.app.call(message)
      }.to change { message['letter'] }.from(nil).to('f')
    end

    context 'call signature' do
      class MiddlewareTwoArguments
        def initialize(app)
          @app = app
        end

        def call(first, second)
          @app.call(first, second)
        end
      end

      let(:expectation) { double(called: true) }

      it 'can handle arbitrary message signatures' do
        expect_any_instance_of(MiddlewareTwoArguments).to receive(:call).with(1, 2).and_call_original
        middlewear.add MiddlewareTwoArguments
        middlewear.app.call(1, 2) do |first, second|
          expectation.called(first)
          expectation.called(second)
        end

        expect(expectation).to have_received(:called).with(1)
        expect(expectation).to have_received(:called).with(2)
      end
    end

    describe 'error handling' do
      before do
        middlewear.add CatchingMiddleWare
        middlewear.add RaisingMiddleware
      end

      it 'can catch error' do
        middlewear.app.call(message)
        expect(message['error_message']).to eq('Raise')
      end

      it 'does not continue through the stack' do
        expectation = double(called: true)
        middlewear.app.call(message) do
          expectation.called
        end
        expect(expectation).not_to have_received(:called)
      end
    end
  end
end
