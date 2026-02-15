import {
  BleError,
  BleManager,
  Characteristic,
  Device,
  ScanMode,
  Subscription,
} from 'react-native-ble-plx';
import {PermissionsAndroid, Platform} from 'react-native';
import base64 from 'base-64';

export const SERVICE_UUID = '4fdb7f0a-96e4-4ecf-8d2b-6f57494701a1';
export const WRITE_CHAR_UUID = '4fdb7f0b-96e4-4ecf-8d2b-6f57494701a1';
export const NOTIFY_CHAR_UUID = '4fdb7f0c-96e4-4ecf-8d2b-6f57494701a1';

export type IncomingEnvelope = {
  from: string;
  to: string;
  payload: {text?: string} | unknown;
  type?: string;
  timestamp?: number;
};

export class BLETransport {
  private manager: BleManager;
  private notifySub: Subscription | null = null;

  constructor() {
    this.manager = new BleManager();
  }

  async requestPermissions(): Promise<boolean> {
    if (Platform.OS !== 'android') {
      return true;
    }

    if (Platform.Version >= 31) {
      const result = await PermissionsAndroid.requestMultiple([
        PermissionsAndroid.PERMISSIONS.BLUETOOTH_SCAN,
        PermissionsAndroid.PERMISSIONS.BLUETOOTH_CONNECT,
        PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
      ]);
      return Object.values(result).every(v => v === PermissionsAndroid.RESULTS.GRANTED);
    }

    const location = await PermissionsAndroid.request(
      PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
    );
    return location === PermissionsAndroid.RESULTS.GRANTED;
  }

  startScan(onDevice: (device: Device) => void, onError: (error: BleError) => void): void {
    this.manager.startDeviceScan(
      [SERVICE_UUID],
      {
        allowDuplicates: false,
        scanMode: ScanMode.LowLatency,
      },
      (error, device) => {
        if (error) {
          onError(error);
          return;
        }
        if (device) {
          onDevice(device);
        }
      },
    );
  }

  stopScan(): void {
    this.manager.stopDeviceScan();
  }

  async connect(deviceId: string, onEnvelope: (envelope: IncomingEnvelope) => void): Promise<Device> {
    const device = await this.manager.connectToDevice(deviceId, {autoConnect: false});
    const ready = await device.discoverAllServicesAndCharacteristics();

    this.notifySub?.remove();
    this.notifySub = ready.monitorCharacteristicForService(
      SERVICE_UUID,
      NOTIFY_CHAR_UUID,
      (error: BleError | null, characteristic: Characteristic | null) => {
        if (error || !characteristic?.value) {
          return;
        }
        try {
          const decoded = base64.decode(characteristic.value);
          const packet = JSON.parse(decoded);
          const env = packet?.env;
          if (env && typeof env === 'object') {
            onEnvelope(env as IncomingEnvelope);
          }
        } catch {
          // Ignore malformed frames.
        }
      },
    );

    return ready;
  }

  async sendEnvelope(deviceId: string, envelope: object): Promise<void> {
    const json = JSON.stringify({kind: 'mesh', env: envelope});
    const encoded = base64.encode(json);

    await this.manager.writeCharacteristicWithResponseForDevice(
      deviceId,
      SERVICE_UUID,
      WRITE_CHAR_UUID,
      encoded,
    );
  }

  async disconnect(deviceId: string): Promise<void> {
    this.notifySub?.remove();
    this.notifySub = null;
    await this.manager.cancelDeviceConnection(deviceId).catch(() => undefined);
  }

  destroy(): void {
    this.notifySub?.remove();
    this.manager.destroy();
  }
}
