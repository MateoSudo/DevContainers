#!/usr/bin/env python3
"""
Data Analysis Example Script

This script demonstrates common data analysis tasks using pandas, numpy, and visualization libraries.
Perfect for getting started with data science in your dev container.

Usage:
    python data_analysis_example.py

Requirements:
    - pandas
    - numpy
    - matplotlib
    - seaborn
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path


def generate_sample_data():
    """Generate sample sales data for demonstration"""
    np.random.seed(42)
    
    # Create sample data
    dates = pd.date_range('2023-01-01', periods=365, freq='D')
    products = ['Product_A', 'Product_B', 'Product_C', 'Product_D', 'Product_E']
    regions = ['North', 'South', 'East', 'West']
    
    data = []
    for date in dates:
        for product in products:
            for region in regions:
                # Generate realistic sales data with some seasonality
                base_sales = np.random.poisson(100)
                seasonal_factor = 1 + 0.3 * np.sin(2 * np.pi * date.dayofyear / 365)
                sales = int(base_sales * seasonal_factor)
                
                data.append({
                    'date': date,
                    'product': product,
                    'region': region,
                    'sales': sales,
                    'revenue': sales * np.random.uniform(10, 50)
                })
    
    return pd.DataFrame(data)


def analyze_sales_data(df):
    """Perform comprehensive sales data analysis"""
    print("=" * 60)
    print("SALES DATA ANALYSIS REPORT")
    print("=" * 60)
    
    # Basic statistics
    print("\n📊 Basic Statistics:")
    print(f"Total Records: {len(df):,}")
    print(f"Date Range: {df['date'].min()} to {df['date'].max()}")
    print(f"Total Revenue: ${df['revenue'].sum():,.2f}")
    print(f"Average Daily Sales: {df['sales'].mean():.1f} units")
    
    # Top performers
    print("\n🏆 Top Performing Products by Revenue:")
    product_revenue = df.groupby('product')['revenue'].sum().sort_values(ascending=False)
    for product, revenue in product_revenue.head().items():
        print(f"  {product}: ${revenue:,.2f}")
    
    print("\n🌟 Top Performing Regions by Sales Volume:")
    region_sales = df.groupby('region')['sales'].sum().sort_values(ascending=False)
    for region, sales in region_sales.head().items():
        print(f"  {region}: {sales:,} units")
    
    return df


def create_visualizations(df):
    """Create comprehensive visualizations"""
    # Set up the plotting style
    plt.style.use('seaborn-v0_8')
    fig, axes = plt.subplots(2, 2, figsize=(15, 12))
    fig.suptitle('Sales Data Analysis Dashboard', fontsize=16, fontweight='bold')
    
    # 1. Revenue by Product (Bar Chart)
    product_revenue = df.groupby('product')['revenue'].sum().sort_values(ascending=False)
    axes[0, 0].bar(product_revenue.index, product_revenue.values, color='skyblue')
    axes[0, 0].set_title('Total Revenue by Product')
    axes[0, 0].set_ylabel('Revenue ($)')
    axes[0, 0].tick_params(axis='x', rotation=45)
    
    # 2. Sales Trend Over Time (Line Chart)
    daily_sales = df.groupby('date')['sales'].sum()
    axes[0, 1].plot(daily_sales.index, daily_sales.values, color='green', alpha=0.7)
    axes[0, 1].set_title('Daily Sales Trend')
    axes[0, 1].set_ylabel('Units Sold')
    axes[0, 1].tick_params(axis='x', rotation=45)
    
    # 3. Regional Performance (Pie Chart)
    region_revenue = df.groupby('region')['revenue'].sum()
    axes[1, 0].pie(region_revenue.values, labels=region_revenue.index, autopct='%1.1f%%')
    axes[1, 0].set_title('Revenue Distribution by Region')
    
    # 4. Product vs Region Heatmap
    pivot_data = df.pivot_table(values='sales', index='product', columns='region', aggfunc='sum')
    sns.heatmap(pivot_data, annot=True, fmt='.0f', cmap='YlOrRd', ax=axes[1, 1])
    axes[1, 1].set_title('Sales Heatmap: Products vs Regions')
    
    plt.tight_layout()
    
    # Save the plot
    output_dir = Path('../data')
    output_dir.mkdir(exist_ok=True)
    plt.savefig(output_dir / 'sales_analysis_dashboard.png', dpi=300, bbox_inches='tight')
    print(f"\n📈 Visualizations saved to: {output_dir / 'sales_analysis_dashboard.png'}")
    
    plt.show()


def export_insights(df):
    """Export key insights to CSV files"""
    output_dir = Path('../data')
    output_dir.mkdir(exist_ok=True)
    
    # Monthly summary
    df['month'] = df['date'].dt.to_period('M')
    monthly_summary = df.groupby('month').agg({
        'sales': 'sum',
        'revenue': 'sum'
    }).reset_index()
    monthly_summary.to_csv(output_dir / 'monthly_summary.csv', index=False)
    
    # Product performance summary
    product_summary = df.groupby('product').agg({
        'sales': ['sum', 'mean'],
        'revenue': ['sum', 'mean']
    }).round(2)
    product_summary.to_csv(output_dir / 'product_performance.csv')
    
    print(f"📁 Data exports saved to: {output_dir}")
    print(f"  - monthly_summary.csv")
    print(f"  - product_performance.csv")


def main():
    """Main execution function"""
    print("🚀 Starting Data Analysis Example...")
    
    # Generate and analyze data
    df = generate_sample_data()
    df = analyze_sales_data(df)
    
    # Create visualizations
    create_visualizations(df)
    
    # Export insights
    export_insights(df)
    
    print("\n✅ Data analysis complete!")
    print("💡 Tip: Check the '../data/' directory for exported files and visualizations")


if __name__ == "__main__":
    main() 