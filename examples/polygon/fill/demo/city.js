import { Scene, PolygonLayer, LineLayer, PointLayer } from '@antv/l7';
import { Mapbox } from '@antv/l7-maps';

const scene = new Scene({
  id: 'map',
  map: new Mapbox({
    pitch: 0,
    style: 'blank',
    center: [ 116.368652, 39.93866 ],
    zoom: 10.07
  })
});
scene.on('loaded', () => {
  fetch(
    'https://gw.alipayobjects.com/os/bmw-prod/707cd4be-8ffe-4778-b863-3335eefd5fd5.json' //  获取行政区划P噢利用
  )
    .then(res => res.json())
    .then(data => {
      const chinaPolygonLayer = new PolygonLayer({
        autoFit: true
      })
        .source(data)
        .color(
          'name',
          [
            'rgb(239,243,255)',
            'rgb(189,215,231)',
            'rgb(107,174,214)',
            'rgb(49,130,189)',
            'rgb(8,81,156)'
          ]
        )
        .shape('fill')
        .style({
          opacity: 1
        });
      //  图层边界
      const layer2 = new LineLayer({
        zIndex: 2
      })
        .source(data)
        .color('rgb(93,112,146)')
        .size(0.6)
        .style({
          opacity: 1
        });

      scene.addLayer(chinaPolygonLayer);
      scene.addLayer(layer2);
    });

  fetch(
    'https://gw.alipayobjects.com/os/basement_prod/ba8fa803-a8c3-4c67-b806-fe1c444546bd.json' //  国界线
  ).then(res => res.json())
    .then(data => {
      const boundaries = new LineLayer({
        zIndex: 2
      })
        .source(data)
        .color('rgb(93,112,146)')
        .size(0.6)
        .style({
          opacity: 1
        });

      scene.addLayer(boundaries);
    });

  fetch(
    'https://gw.alipayobjects.com/os/bmw-prod/d09a3567-8c0e-4711-b8b8-cd82e8870e4b.json' //  标注数据
  ).then(res => res.json())
    .then(data => {
      const labelLayer = new PointLayer({
        zIndex: 5
      })
        .source(data, {
          parser: {
            type: 'json',
            coordinates: 'center'
          }
        })
        .color('#fff')
        .shape('name', 'text')
        .size(12)
        .style({
          opacity: 1,
          stroke: '#fff',
          strokeWidth: 0,
          padding: [ 5, 5 ],
          textAllowOverlap: false
        });

      scene.addLayer(labelLayer);
    });
});
