export function removeC2C(str: string): string {
  return str.replace(/C2C/g, '');
}

export function isJSON(str: string) {
  if (typeof str === 'string') {
    try {
      const data = JSON.parse(str);
      if (data) {
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }
  return false;
}

export function JSONToObject(str: string) {
  if (!str || !isJSON(str)) {
    return str;
  }
  return JSON.parse(str);
}

export function formatDuration(seconds: number): string {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const secs = seconds % 60;

  if (hours > 0) {
    return [
      hours.toString().padStart(2, '0'),
      minutes.toString().padStart(2, '0'),
      secs.toString().padStart(2, '0'),
    ].join(':');
  }

  return [
    minutes.toString().padStart(2, '0'),
    secs.toString().padStart(2, '0'),
  ].join(':');
}
