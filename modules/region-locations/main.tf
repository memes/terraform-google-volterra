terraform {
  required_version = ">= 0.13.0"
}

locals {
  # Note: these values are either the location of a known Google data center
  # (as published at https://www.google.com/about/datacenters/locations/) or
  # the lat/long returned by Google Maps when looking up the city associated
  # with the region.
  lookup = {
    # Taiwan
    asia-east1 = {
      latitude  = 23.9920779
      longitude = 120.3931135
    }
    # Hong Kong
    asia-east2 = {
      latitude  = 22.3528672
      longitude = 114.0576607
    }
    # Tokyo
    asia-northeast1 = {
      latitude  = 35.5090628
      longitude = 139.2094226
    }
    # Osaka
    asia-northeast2 = {
      latitude  = 34.6776637
      longitude = 135.4510181
    }
    # Seoul
    asia-northeast3 = {
      latitude  = 37.5652154
      longitude = 126.9195108
    }
    # Mumbai
    asia-south1 = {
      latitude  = 19.0823998
      longitude = 72.8111468
    }
    # Delhi
    asia-south2 = {
      latitude  = 28.6471948
      longitude = 76.9531819
    }
    # Singapore
    asia-southeast1 = {
      latitude  = 1.3141707
      longitude = 103.7742107
    }
    # Jakarta
    asia-southeast2 = {
      latitude  = -6.2295712
      longitude = 106.7594787
    }
    # Sydney
    australia-southeast1 = {
      latitude  = -33.8478796
      longitude = 150.7918945
    }
    # Melbourne
    australia-southeast2 = {
      latitude  = -37.9716929
      longitude = 144.772967
    }
    # Warsaw
    europe-central2 = {
      latitude  = 52.2330224
      longitude = 20.9911552
    }
    # Finland
    europe-north1 = {
      latitude  = 60.5696111
      longitude = 27.1922336
    }
    # Belgium
    europe-west1 = {
      latitude  = 50.4898944
      longitude = 3.7729007
    }
    # London
    europe-west2 = {
      latitude  = 51.5287718
      longitude = -0.2416787
    }
    # Frankfurt
    europe-west3 = {
      latitude  = 50.121301
      longitude = 8.5665248
    }
    # Netherlands
    europe-west4 = {
      latitude  = 53.435673
      longitude = 6.8155881
    }
    # Zurich
    europe-west6 = {
      latitude  = 47.3775078
      longitude = 8.5016958
    }
    # Montreal
    northamerica-northeast1 = {
      latitude  = 45.5581408
      longitude = -73.8003415
    }
    # Sao Paulo
    southamerica-east1 = {
      latitude  = -23.682035
      longitude = -46.7353802
    }
    # Iowa
    us-central1 = {
      latitude  = 41.0225597
      longitude = -96.2619721
    }
    # South Carolina
    us-east1 = {
      latitude  = 33.16441
      longitude = -80.0442632
    }
    # N. Virgnia
    us-east4 = {
      latitude  = 39.0856657
      longitude = -77.7842803
    }
    # Oregon
    us-west1 = {
      latitude  = 45.6319089
      longitude = 121.2032169
    }
    # Los Angeles
    us-west2 = {
      latitude  = 34.0207305
      longitude = -118.6919199
    }
    # Salt Lake City
    us-west3 = {
      latitude  = 40.7767833
      longitude = -112.060569
    }
    # Las Vegas
    us-west4 = {
      latitude  = 36.0546162
      longitude = -115.0072807
    }
  }
}
