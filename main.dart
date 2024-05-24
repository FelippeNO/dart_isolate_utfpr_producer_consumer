import 'dart:async';
import 'dart:isolate';

// Função do produtor que gera números
void producer(SendPort sendPort) {
  int count = 0;
  Timer.periodic(Duration(seconds: 1), (timer) {
    count++;
    sendPort.send(count);
    print('Produced: $count');
  });
}

// Função do consumidor que recebe e processa números
void consumer(SendPort sendPort) {
  ReceivePort receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    print('Consumed: $message');
  });
}

void main() {
  // Isolate do produtor
  ReceivePort producerReceivePort = ReceivePort();
  Isolate.spawn(producer, producerReceivePort.sendPort);

  // Isolate do consumidor
  ReceivePort consumerReceivePort = ReceivePort();
  Isolate.spawn(consumer, consumerReceivePort.sendPort);

  // Estabelecer comunicação entre produtor e consumidor
  consumerReceivePort.listen((consumerSendPort) {
    producerReceivePort.listen((message) {
      consumerSendPort.send(message);
    });
  });
}
