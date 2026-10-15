import type { Location } from "#shared/types/Location";

export const useLocations = () => {
  const locations = useState<Location[]>("locations", () => [] as Location[]);
  /**
   * Updates the locations state with the provided partial data.
   * @param data - Partial location object containing the properties to update
   */
  const setLocations = (data: Partial<Location>) => {
    Object.assign(locations.value, data);
  };

  const resetLocations = () => {
    Object.assign(locations.value, []);
  };

  return {
    locations,
    setLocations,
    resetLocations,
  };
};
