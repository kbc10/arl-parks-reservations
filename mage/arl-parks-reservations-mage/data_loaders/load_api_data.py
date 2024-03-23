import io
import pandas as pd
import requests
if 'data_loader' not in globals():
    from mage_ai.data_preparation.decorators import data_loader
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@data_loader
def load_data_from_api(*args, **kwargs):
    """
    Template for loading data from API
    """
    url = 'https://download.data.arlingtonva.us/Recreation/ParkFacilityReservations.txt.gz?v=1711094631&_gl=1*69s0s*_ga*MTY4Mzg3Nzg1My4xNzA2NjIzODY1*_ga_BSNCGMV709*MTcxMTEyMjkwOS40LjEuMTcxMTEyNDE2OS4yMS4wLjE2NjE5NjAzNTM.'
    reservation_dtypes = {
        'ParkFacilityReservationKey': pd.Int64Dtype(),
        'LocationName': str, 
        'FacilityName': str,
        'StreetAddressText': str,
        'CityName': str,
        'ZipCode': pd.Int64Dtype(),
        'LatitudeAndLongitudeCrd': str, 
        'ReservationDsc': str,
        'FacilityLocationCode': str,
        'FacilitySpaceCode': str,
        'CustomerName': str,
        'CustomerFirstName': str,
        'CustomerLastName': str, 
        'HouseholdNbr': pd.Int64Dtype(),
        'HeadCnt': pd.Int64Dtype(),
        'ReservationPurposeDsc': str,
        'ComboKeyCode': str,
        'FacilityParentCode': str,
        'FacilityChildCodeList': str, 
        'FacilitySiblingCodeList': str,
        'ReservationFacilityTypeCode': str,
        'ReservationTypeName': str, 
        'FeatureCodeList': str,
        'LightedFieldInd': str,
        'FieldTurfTypeDsc': str,
        'FieldOperationalStatusDsc': str, 
        'ReservationStatusCode': str, 
        'CalendarIncludeInd': str,
        'FieldUseTypeDsc': str,
        'ParkUrlText': str,
    }

    parse_dates = ['TransactionDtm', 'ReservationBeginDtm', 'ReservationEndDtm']

    return pd.read_csv(url, compression='gzip', dtype=reservation_dtypes, parse_dates=parse_dates, sep='|')


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
