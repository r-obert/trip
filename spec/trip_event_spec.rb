require_relative 'setup'
RSpec.describe Trip::Event do
  class DummyClass
    def self.run(x,y)
      sum = x + y
    end
  end

  let(:trip) do
    Trip.new { DummyClass.run(2,5) }
  end

  after do
    trip.stop
  end

  describe '#type' do
    describe 'call and return of method implemented in Ruby' do
      it 'returns "call"' do
        event = trip.start
        expect(event.type).to eq('call')
      end

      it 'returns "return"' do
        trip.start
        event = trip.resume
        expect(event.type).to eq('return')
      end
    end

    describe 'call and return of method implemented in C' do
      let(:trip) do
        trip = Trip.new { Kernel.print '' }
        trip.pause_when { |event| event.from_module == Kernel and event.from_method == :print }
        trip
      end

      it 'returns "c-call"' do
        event = trip.start
        expect(event.type).to eq('c-call')
      end

      it 'returns "c-return"' do
        trip.start
        event = trip.resume
        expect(event.type).to eq('c-return')
      end
    end
  end

  describe '#from_module' do
    it 'returns the Module from where an event originated' do
      event = trip.start
      expect(event.from_module).to eq(DummyClass)
    end
  end

  describe '#from_method' do
    it 'returns the type of the method where an event originated' do
      event = trip.start
      expect(event.from_method).to eq(:run)
    end
  end

  describe '#file' do
    it 'returns __FILE__' do
      event = trip.start
      expect(event.file).to eq(__FILE__)
    end
  end

  describe '#lineno' do
    it 'returns __LINE__' do
      event = trip.start
      expect(event.lineno).to eq(4)
    end
  end

  describe '#binding' do
    it 'returns a binding' do
      event = trip.start
      expect(event.binding).to be_instance_of(Binding)
    end

    it 'changes value of "x"' do
      event = trip.start
      event.binding.eval('x = 4')
      event = trip.resume
      expect(event.binding.eval('sum')).to eq(9)
    end
  end

  describe '#__binding__' do
    it 'returns a binding for instance of Trip::Event' do
      event = trip.start
      expect(Trip::Event === event.__binding__.eval('self')).to eq(true)
    end
  end

  describe '#inspect' do
    it 'returns a String' do
      event = trip.start
      expect(event.inspect).to be_instance_of(String)
    end
  end
end
