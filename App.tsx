import React, {useEffect, useMemo, useState} from 'react';
import {
  Alert,
  FlatList,
  Pressable,
  SafeAreaView,
  StatusBar,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import type {Device} from 'react-native-ble-plx';
import {BLETransport, IncomingEnvelope} from './src/services/bleTransport';

type ChatMessage = {
  id: string;
  author: 'me' | 'peer' | 'system';
  text: string;
  ts: number;
};

function newNodeId(): string {
  return `mob-${Math.random().toString(16).slice(2, 8)}`;
}

function newMsgId(): string {
  return `${Date.now()}-${Math.random().toString(16).slice(2, 10)}`;
}

function App(): React.JSX.Element {
  const nodeId = useMemo(() => newNodeId(), []);
  const [ble] = useState(() => new BLETransport());

  const [peers, setPeers] = useState<Record<string, Device>>({});
  const [selectedPeerId, setSelectedPeerId] = useState<string>('');
  const [connectedPeerId, setConnectedPeerId] = useState<string>('');
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [draft, setDraft] = useState<string>('');
  const [scanning, setScanning] = useState<boolean>(false);

  useEffect(() => {
    return () => {
      ble.stopScan();
      if (connectedPeerId) {
        ble.disconnect(connectedPeerId).catch(() => undefined);
      }
      ble.destroy();
    };
  }, [ble, connectedPeerId]);

  function pushMessage(message: ChatMessage): void {
    setMessages(prev => [...prev, message]);
  }

  async function grantPermissions(): Promise<void> {
    const ok = await ble.requestPermissions();
    if (!ok) {
      Alert.alert('Permission required', 'Bluetooth permissions are required to scan and connect.');
    } else {
      pushMessage({
        id: newMsgId(),
        author: 'system',
        text: 'Permissions granted.',
        ts: Date.now(),
      });
    }
  }

  function startScan(): void {
    setScanning(true);
    setPeers({});

    ble.startScan(
      device => {
        setPeers(prev => ({...prev, [device.id]: device}));
      },
      error => {
        setScanning(false);
        pushMessage({
          id: newMsgId(),
          author: 'system',
          text: `Scan failed: ${error.message}`,
          ts: Date.now(),
        });
      },
    );
  }

  function stopScan(): void {
    ble.stopScan();
    setScanning(false);
  }

  async function connectToPeer(): Promise<void> {
    if (!selectedPeerId) {
      Alert.alert('Select device', 'Pick a discovered device first.');
      return;
    }

    try {
      const device = await ble.connect(selectedPeerId, (env: IncomingEnvelope) => {
        const payload = env.payload as {text?: string};
        pushMessage({
          id: newMsgId(),
          author: 'peer',
          text: payload?.text || '[non-text payload]',
          ts: Date.now(),
        });
      });
      setConnectedPeerId(device.id);
      pushMessage({
        id: newMsgId(),
        author: 'system',
        text: `Connected to ${device.name || device.id}`,
        ts: Date.now(),
      });
    } catch (err) {
      const text = err instanceof Error ? err.message : String(err);
      pushMessage({
        id: newMsgId(),
        author: 'system',
        text: `Connect failed: ${text}`,
        ts: Date.now(),
      });
    }
  }

  async function sendText(): Promise<void> {
    const text = draft.trim();
    if (!text || !connectedPeerId) {
      return;
    }

    const envelope = {
      msg_id: newMsgId(),
      from: nodeId,
      to: connectedPeerId,
      ttl: 6,
      hop: 0,
      timestamp: Date.now() / 1000,
      type: 'text',
      payload: {text},
      enc: 'none',
      reply_to: null,
    };

    try {
      await ble.sendEnvelope(connectedPeerId, envelope);
      pushMessage({id: envelope.msg_id, author: 'me', text, ts: Date.now()});
      setDraft('');
    } catch (err) {
      const errorText = err instanceof Error ? err.message : String(err);
      pushMessage({
        id: newMsgId(),
        author: 'system',
        text: `Send failed: ${errorText}`,
        ts: Date.now(),
      });
    }
  }

  const peerList = Object.values(peers);

  return (
    <SafeAreaView style={styles.safe}>
      <StatusBar barStyle="light-content" />
      <View style={styles.root}>
        <Text style={styles.title}>BigHeads Mobile MVP</Text>
        <Text style={styles.subtitle}>Node: {nodeId}</Text>

        <View style={styles.controlsRow}>
          <ActionButton text="Perm" onPress={grantPermissions} />
          <ActionButton text={scanning ? 'Scanning...' : 'Scan'} onPress={startScan} />
          <ActionButton text="Stop" onPress={stopScan} />
          <ActionButton text="Connect" onPress={connectToPeer} />
        </View>

        <Text style={styles.sectionTitle}>Nearby devices</Text>
        <FlatList
          data={peerList}
          keyExtractor={item => item.id}
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.peerList}
          renderItem={({item}) => {
            const active = selectedPeerId === item.id;
            return (
              <Pressable
                style={[styles.peerChip, active && styles.peerChipActive]}
                onPress={() => setSelectedPeerId(item.id)}>
                <Text style={styles.peerName}>{item.name || 'Unnamed'}</Text>
                <Text style={styles.peerId}>{item.id.slice(0, 12)}</Text>
              </Pressable>
            );
          }}
        />

        <Text style={styles.sectionTitle}>Chat</Text>
        <FlatList
          data={messages}
          keyExtractor={item => item.id}
          contentContainerStyle={styles.chatList}
          renderItem={({item}) => (
            <View
              style={[
                styles.bubble,
                item.author === 'me' && styles.bubbleMe,
                item.author === 'peer' && styles.bubblePeer,
                item.author === 'system' && styles.bubbleSystem,
              ]}>
              <Text style={styles.bubbleText}>{item.text}</Text>
            </View>
          )}
        />

        <View style={styles.composer}>
          <TextInput
            value={draft}
            onChangeText={setDraft}
            placeholder={connectedPeerId ? 'Type message...' : 'Connect to a device first'}
            placeholderTextColor="#7a8ea8"
            style={styles.input}
            editable={!!connectedPeerId}
          />
          <ActionButton text="Send" onPress={sendText} />
        </View>
      </View>
    </SafeAreaView>
  );
}

function ActionButton({text, onPress}: {text: string; onPress: () => void}): React.JSX.Element {
  return (
    <Pressable style={styles.button} onPress={onPress}>
      <Text style={styles.buttonText}>{text}</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  safe: {flex: 1, backgroundColor: '#07131f'},
  root: {flex: 1, paddingHorizontal: 14, paddingTop: 8, paddingBottom: 10},
  title: {color: '#f6fbff', fontSize: 22, fontWeight: '700'},
  subtitle: {color: '#86a7c9', marginTop: 4, marginBottom: 10, fontSize: 12},
  controlsRow: {flexDirection: 'row', gap: 8, marginBottom: 10},
  sectionTitle: {color: '#f6fbff', fontSize: 14, fontWeight: '600', marginBottom: 8},
  peerList: {paddingBottom: 8, gap: 8},
  peerChip: {
    backgroundColor: '#102235',
    borderColor: '#25445f',
    borderWidth: 1,
    borderRadius: 12,
    paddingHorizontal: 10,
    paddingVertical: 8,
    minWidth: 130,
  },
  peerChipActive: {borderColor: '#72c7ff', backgroundColor: '#12304b'},
  peerName: {color: '#e8f4ff', fontSize: 13, fontWeight: '600'},
  peerId: {color: '#8caac4', fontSize: 11, marginTop: 2},
  chatList: {paddingBottom: 10, gap: 8},
  bubble: {borderRadius: 14, paddingHorizontal: 12, paddingVertical: 9, maxWidth: '86%'},
  bubbleMe: {backgroundColor: '#1e5c8f', alignSelf: 'flex-end'},
  bubblePeer: {backgroundColor: '#1d3349', alignSelf: 'flex-start'},
  bubbleSystem: {backgroundColor: '#2f2f38', alignSelf: 'center'},
  bubbleText: {color: '#f1f8ff', fontSize: 14},
  composer: {
    flexDirection: 'row',
    alignItems: 'center',
    borderTopWidth: 1,
    borderTopColor: '#23384d',
    paddingTop: 10,
    gap: 8,
  },
  input: {
    flex: 1,
    backgroundColor: '#102235',
    borderRadius: 10,
    borderWidth: 1,
    borderColor: '#304a63',
    color: '#f6fbff',
    paddingHorizontal: 12,
    paddingVertical: 10,
  },
  button: {
    backgroundColor: '#2a7fc2',
    borderRadius: 10,
    paddingHorizontal: 12,
    paddingVertical: 10,
  },
  buttonText: {color: '#ffffff', fontWeight: '700', fontSize: 13},
});

export default App;
