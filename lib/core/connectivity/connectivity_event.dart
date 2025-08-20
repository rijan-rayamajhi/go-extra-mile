abstract class ConnectivityEvent {}

class CheckConnectivityEvent extends ConnectivityEvent {}

class ConnectivityChangedEvent extends ConnectivityEvent {
  final bool isConnected;
  
  ConnectivityChangedEvent(this.isConnected);
}

class RetryConnectionEvent extends ConnectivityEvent {}