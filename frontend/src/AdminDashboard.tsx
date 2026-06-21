import React, { useState, useEffect } from 'react';

export const AdminDashboard: React.FC = () => {
  const [metrics, setMetrics] = useState({
    totalUsers: 3,
    totalDrivers: 1,
    totalRides: 0,
    activeRides: 0,
    systemStatus: 'Healthy'
  });

  return (
    <div style={{
      fontFamily: "'Poppins', 'Roboto', sans-serif",
      backgroundColor: '#1E1E1E',
      color: '#FFFFFF',
      minHeight: '100vh',
      padding: '24px'
    }}>
      {/* Top Header Bar */}
      <header style={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        borderBottom: '2px solid #2C2C2C',
        paddingBottom: '16px',
        marginBottom: '32px'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div style={{
            width: '40px',
            height: '40px',
            borderRadius: '50%',
            backgroundColor: '#FFC107',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontWeight: 'bold',
            color: '#2C2C2C'
          }}>TG</div>
          <h1 style={{ margin: 0, fontSize: '24px', color: '#FFC107' }}>TricyGo Admin</h1>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
          <span style={{
            backgroundColor: '#1DB954',
            color: '#FFFFFF',
            padding: '6px 12px',
            borderRadius: '20px',
            fontSize: '12px',
            fontWeight: 'bold'
          }}>● System Live</span>
          <span style={{ color: '#AAAAAA' }}>Welcome, Administrator</span>
        </div>
      </header>

      {/* Main KPI Matrix Grid Rows */}
      <main>
        <section style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
          gap: '20px',
          marginBottom: '32px'
        }}>
          <div style={{ backgroundColor: '#2C2C2C', padding: '24px', borderRadius: '12px', borderLeft: '4px solid #FFC107' }}>
            <h3 style={{ margin: '0 0 8px 0', color: '#AAAAAA', fontSize: '14px', textTransform: 'uppercase' }}>Total Registered Users</h3>
            <p style={{ margin: 0, fontSize: '32px', fontWeight: 'bold' }}>{metrics.totalUsers}</p>
          </div>

          <div style={{ backgroundColor: '#2C2C2C', padding: '24px', borderRadius: '12px', borderLeft: '4px solid #1DB954' }}>
            <h3 style={{ margin: '0 0 8px 0', color: '#AAAAAA', fontSize: '14px', textTransform: 'uppercase' }}>Active Tricycles</h3>
            <p style={{ margin: 0, fontSize: '32px', fontWeight: 'bold' }}>{metrics.totalDrivers}</p>
          </div>

          <div style={{ backgroundColor: '#2C2C2C', padding: '24px', borderRadius: '12px', borderLeft: '4px solid #00BCD4' }}>
            <h3 style={{ margin: '0 0 8px 0', color: '#AAAAAA', fontSize: '14px', textTransform: 'uppercase' }}>Total Rides Completed</h3>
            <p style={{ margin: 0, fontSize: '32px', fontWeight: 'bold' }}>{metrics.totalRides}</p>
          </div>

          <div style={{ backgroundColor: '#2C2C2C', padding: '24px', borderRadius: '12px', borderLeft: '4px solid #E91E63' }}>
            <h3 style={{ margin: '0 0 8px 0', color: '#AAAAAA', fontSize: '14px', textTransform: 'uppercase' }}>Live Monitored Trips</h3>
            <p style={{ margin: 0, fontSize: '32px', fontWeight: 'bold', color: '#E91E63' }}>{metrics.activeRides}</p>
          </div>
        </section>

        {/* Real-time Simulator Panel Row Map */}
        <section style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '24px' }}>
          <div style={{ backgroundColor: '#2C2C2C', padding: '24px', borderRadius: '12px', minHeight: '300px' }}>
            <h2 style={{ margin: '0 0 16px 0', fontSize: '18px', color: '#FFC107' }}>Live Operational Grid View Map</h2>
            <div style={{
              width: '100%',
              height: '80%',
              backgroundColor: '#1E1E1E',
              borderRadius: '8px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#666666',
              border: '1px dashed #444444'
            }}>
              [ Interactive PostGIS Map Matrix Grid Simulation Layer ]
            </div>
          </div>

          <div style={{ backgroundColor: '#2C2C2C', padding: '24px', borderRadius: '12px' }}>
            <h2 style={{ margin: '0 0 16px 0', fontSize: '18px', color: '#FFC107' }}>System Alerts / Audit</h2>
            <ul style={{ listStyle: 'none', padding: 0, margin: 0, fontSize: '14px', color: '#DDDDDD' }}>
              <li style={{ padding: '8px 0', borderBottom: '1px solid #3D3D3D' }}>
                <span style={{ color: '#1DB954' }}>[INFO]</span> Database initialized.
              </li>
              <li style={{ padding: '8px 0', borderBottom: '1px solid #3D3D3D' }}>
                <span style={{ color: '#FFC107' }}>[WARN]</span> Driver pool listening on port 3000 WebSocket gateway.
              </li>
            </ul>
          </div>
        </section>
      </main>
    </div>
  );
};
export default AdminDashboard;
