typedef EventCallback = void Function(dynamic arg);

class EventBus {
  EventBus._newObject();

  static final EventBus _singleton = EventBus._newObject();

  factory EventBus() => _singleton;

  final _messageQueue = <Object, List<EventCallback>>{};

  void register(eventName, EventCallback? callback) {
    if (eventName != null && callback != null) {
      if (_messageQueue[eventName] == null) {
        _messageQueue[eventName] = <EventCallback>[];
      }
      _messageQueue[eventName]?.add(callback);
    }
  }

  void unregister(eventName, EventCallback? callback) {
    if (eventName != null && callback != null) {
      var list = _messageQueue[eventName];
      if (list != null) {
        list.remove(callback);
      }
    }
  }

  void notify(eventName, [arg]) {
    var list = _messageQueue[eventName];
    if (list != null && list.isNotEmpty) {
      for (var i = 0; i < list.length; i++) {
        list[i](arg);
      }
    }
  }
}

final eventBus = EventBus();
const setStateEvent = 'SET_STATE_EVENT';
const setStateEventOnCallReceived = 'SET_STATE_EVENT_ONCALLRECEIVED';
const setStateEventOnCallEnd = 'SET_STATE_EVENT_ONCALLEND';
const setStateEventRefreshTiming = 'SET_STATE_EVENT_REFRESH_TIMING';
const setStateEventOnCallBegin = 'SET_STATE_EVENT_CALLBEGIN';
