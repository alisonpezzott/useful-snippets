### Dinamic Range Currency

```

VAR __Value = SELECTEDMEASURE()
VAR __Ref = ABS(__Value)

VAR __Format = 
  SWITCH( 
    TRUE(),
      __Ref >= POWER(10, 12), "R$ #,0,,,,.0 Tri;(R$ #,0,,,,.0 Tri);-",
      __Ref >= POWER(10, 9),  "R$ #,0,,,.0 Bi;(R$ #,0,,,.0 Bi);-",
      __Ref >= POWER(10, 6),  "R$ #,0,,.0 Mi;(R$ #,0,,.0 Mi);-",
      __Ref >= POWER(10, 3),  "R$ #,0,.0 K;(R$ #,0,.0 K);-",
                              "R$ #,0.0;(R$ #,0.0);-"
    )

VAR __Result =
  """" & FORMAT(__Value, __Format) & """"

RETURN
    __Result

```

### Percent with symbols  

```
""""& FORMAT(SELECTEDMEASURE(), "🡥 0.0%;🡧 0.0%;-") &""""
```

